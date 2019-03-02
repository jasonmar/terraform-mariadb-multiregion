/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  runid = "${substr(uuid(),0,4)}"
}

data "google_compute_network" "default" {
  project = "${var.xpn_project}"
  name    = "${var.network}"
}

resource "google_compute_address" "mariadb" {
  count        = "${var.instance_count}"
  project      = "${var.project}"
  name         = "${format("mariadb-${var.cluster_name}-%03d", count.index)}"
  subnetwork   = "projects/${var.xpn_project}/regions/${lookup(var.region, count.index)}/subnetworks/${lookup(var.subnetwork, count.index)}"
  address_type = "INTERNAL"
  region       = "${lookup(var.region, count.index)}"
}

data "template_file" "config" {
  template = "${file("${path.module}/scripts/mariadb.sh.tpl")}"
  vars = {
    idx = "${count.index}"
    mariadb0 = "${google_compute_address.mariadb.*.address[count.index]}"
    mariadb1 = "${google_compute_address.mariadb.*.address[count.index+1]}"
    pass = "${var.pass}"
    replpass = "${var.replpass}"
    config_bucket = "${var.config_bucket}"
    cluster_name = "${var.cluster_name}"
    service_account = "${var.service_account}"
    project_name = "${var.project}"
    databases = "${var.databases}"
  }
}

resource "google_storage_bucket_object" "config" {
  name    = "${var.cluster_name}/mariadb_${local.runid}.sh"
  content = "${data.template_file.config.rendered}"
  bucket  = "${var.config_bucket}"
}

data "template_file" "startup" {
  template = "${file("${path.module}/scripts/startup.sh.tpl")}"
  vars = {
    script_path = "gs://${var.config_bucket}/${google_storage_bucket_object.config.name}"
  }
}

resource "google_compute_instance_template" "mariadb" {
  count                = "${var.instance_count}"
  project              = "${var.project}"
  name                 = "mariadb-${var.cluster_name}-${count.index}"
  description          = "MariaDB Instance Template"
  instance_description = "MariaDB Server"
  machine_type         = "${var.instance_type}"
  can_ip_forward       = false
  tags                 = ["mariadb"]
  labels = {
    template = "tf-mariadb"
    cluster_name = "${var.cluster_name}"
  }
  metadata {
    startup-script = "${data.template_file.startup.rendered}"
  }
  disk {
    source_image = "debian-cloud/debian-9"
    disk_size_gb = "${var.disk_size_gb}"
    type         = "${var.disk_type}"
  }
  network_interface {
    subnetwork = "projects/${var.xpn_project}/regions/${lookup(var.region, count.index)}/subnetworks/${lookup(var.subnetwork, count.index)}"
    network_ip = "${google_compute_address.mariadb.*.address[count.index]}"
  }
  service_account {
    email  = "${var.service_account}@${var.project}.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "mariadb" {
  count              = "${var.instance_count}"
  provider           = "google-beta"
  project            = "${var.project}"
  name               = "${format("mariadb-${var.cluster_name}-%03d", count.index)}"
  base_instance_name = "${format("mariadb-${var.cluster_name}-%03d", count.index)}"
  zone               = "${lookup(var.zone, count.index)}"
  target_size        = 1
  version {
    name              = "v1"
    instance_template = "${google_compute_instance_template.mariadb.*.self_link[count.index]}"
  }
  update_policy {
    minimal_action        = "REPLACE"
    type                  = "PROACTIVE"
    max_unavailable_fixed = "1"
  }
  auto_healing_policies {
    health_check      = "projects/${var.project}/global/healthChecks/${var.health_check}"
    initial_delay_sec = 300
  }
}
