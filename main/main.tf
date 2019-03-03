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

resource "google_compute_address" "mariadb" {
  count        = "${var.instance_count}"
  project      = "${var.project}"
  name         = "${format("mariadb-${var.cluster_name}-%03d", count.index)}"
  subnetwork   = "projects/${var.xpn_project}/regions/${lookup(var.region, count.index)}/subnetworks/${lookup(var.subnetwork, count.index)}"
  address_type = "INTERNAL"
  region       = "${lookup(var.region, count.index)}"
}

data "template_file" "mariadb" {
  template = "${file("${path.module}/scripts/mariadb.sh.tpl")}"
  vars = {
    pass = "${var.pass}"
    replpass = "${var.replpass}"
    statspass = "${var.statspass}"
  }
}

data "template_file" "garb" {
  template = "${file("${path.module}/scripts/garb.sh.tpl")}"
  vars = {
    cluster-name = "${var.cluster_name}"
    config-bucket = "${var.config_bucket}"
  }
}

resource "google_storage_bucket_object" "config" {
  name    = "${var.cluster_name}/mariadb.sh"
  content = "${data.template_file.mariadb.rendered}"
  bucket  = "${var.config_bucket}"
}

resource "google_storage_bucket_object" "ca" {
  name   = "${var.cluster_name}/ca.crt"
  source = "${path.module}/ssl/ca.crt"
  bucket = "${var.config_bucket}"
}

resource "google_storage_bucket_object" "garbcert" {
  name   = "${var.cluster_name}/garb.crt"
  source = "${path.module}/ssl/garb.crt"
  bucket = "${var.config_bucket}"
}

resource "google_storage_bucket_object" "garbkey" {
  name   = "${var.cluster_name}/garb.pem"
  source = "${path.module}/ssl/garb.pem"
  bucket = "${var.config_bucket}"
}

resource "google_storage_bucket_object" "garb" {
  name    = "${var.cluster_name}/garb.sh"
  content = "${data.template_file.garb.rendered}"
  bucket  = "${var.config_bucket}"
}

resource "google_storage_bucket_object" "certs" {
  count  = "${var.instance_count}"
  name   = "${var.cluster_name}/${count.index}.crt"
  source = "${path.module}/ssl/${count.index}.crt"
  bucket = "${var.config_bucket}"
}

resource "google_storage_bucket_object" "keys" {
  count  = "${var.instance_count}"
  name   = "${var.cluster_name}/${count.index}.pem"
  source = "${path.module}/ssl/${count.index}.pem"
  bucket = "${var.config_bucket}"
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
  name                 = "mariadb-${var.cluster_name}-${count.index}-${var.template_version}"
  description          = "MariaDB Instance Template"
  instance_description = "MariaDB Server"
  machine_type         = "${var.instance_type}"
  can_ip_forward       = false
  tags                 = ["mariadb","internal"]
  labels = {
    template = "tf-mariadb"
    cluster_name = "${var.cluster_name}"
  }
  metadata {
    startup-script  = "${data.template_file.startup.rendered}"
    node-id         = "${count.index}"
    cluster-name    = "${var.cluster_name}"
    cluster-members = "${google_compute_address.mariadb.*.address[0]},${google_compute_address.mariadb.*.address[1]},${google_compute_address.mariadb.*.address[2]},${google_compute_address.mariadb.*.address[3]}"
    config-bucket   = "${var.config_bucket}"
    databases       = "${var.databases}"
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
    type                  = "OPPORTUNISTIC"
    max_unavailable_fixed = "1"
  }
  auto_healing_policies {
    health_check      = "projects/${var.project}/global/healthChecks/${var.health_check}"
    initial_delay_sec = 300
  }
}

data "template_file" "garb_startup" {
  template = "${file("${path.module}/scripts/startup.sh.tpl")}"
  vars = {
    script_path = "gs://${var.config_bucket}/${google_storage_bucket_object.garb.name}"
  }
}

resource "google_compute_instance_template" "garb" {
  project              = "${var.project}"
  name                 = "mariadb-${var.cluster_name}-garb-${var.template_version}"
  description          = "MariaDB Galera Arbitrator Instance Template"
  instance_description = "MariaDB Galera Arbitrator"
  machine_type         = "${var.garb_instance_type}"
  can_ip_forward       = false
  tags                 = ["mariadb","internal"]
  labels = {
    template = "tf-mariadb"
    cluster_name = "${var.cluster_name}"
  }
  metadata {
    startup-script  = "${data.template_file.garb_startup.rendered}"
    cluster-name    = "${var.cluster_name}"
    node-id         = "garb"
    config-bucket   = "${var.config_bucket}"
    cluster-members = "${google_compute_address.mariadb.*.address[0]},${google_compute_address.mariadb.*.address[1]},${google_compute_address.mariadb.*.address[2]},${google_compute_address.mariadb.*.address[3]}"
  }
  disk {
    source_image = "debian-cloud/debian-9"
    disk_size_gb = "32"
    type         = "pd-standard"
  }
  network_interface {
    subnetwork = "projects/${var.xpn_project}/regions/${var.garb_region}/subnetworks/${var.garb_subnetwork}"
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

resource "google_compute_instance_group_manager" "garb" {
  provider           = "google-beta"
  project            = "${var.project}"
  name               = "mariadb-${var.cluster_name}-garb"
  base_instance_name = "mariadb-${var.cluster_name}-garb"
  zone               = "${var.garb_zone}"
  target_size        = 1
  version {
    name              = "v1"
    instance_template = "${google_compute_instance_template.garb.self_link}"
  }
  update_policy {
    minimal_action        = "REPLACE"
    type                  = "OPPORTUNISTIC"
    max_unavailable_fixed = "1"
  }
}