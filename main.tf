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

provider "google-beta" {
  # https://github.com/terraform-providers/terraform-provider-google-beta/blob/master/google-beta/
  #credentials = "${file("account.json")}"
  project     = "${var.project}"
  region      = "${var.region0}"
}

locals {
  runid = "${substr(uuid(),0,4)}"
}

resource "google_compute_instance_template" "mariadb0" {
  project              = "${var.project}"
  name                 = "mariadb0-${local.runid}"
  description          = "mariadb instance template"
  instance_description = "mariadb Server"
  machine_type         = "${var.instance_type}"
  can_ip_forward       = false
  tags                 = ["mariadb"]

  labels = {
    template = "tf-mariadb"
  }

  metadata {
    startup-script = "${data.template_file.startup.rendered}"
  }

  disk {
    source_image = "debian-cloud/debian-9"
    disk_size_gb = 128
    type         = "pd-standard"
  }

  network_interface {
    subnetwork         = "${data.google_compute_subnetwork.subnetwork0.self_link}"
    subnetwork_project = "${data.google_compute_subnetwork.subnetwork0.project}"
    network_ip = "${google_compute_address.mariadb0.address}"
  }

  service_account {
    email  = "${google_service_account.mariadb.email}"
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

resource "google_compute_instance_template" "mariadb1" {
  project              = "${var.project}"
  name                 = "mariadb1-${local.runid}"
  description          = "mariadb instance template"
  instance_description = "mariadb Server"
  machine_type         = "${var.instance_type}"
  can_ip_forward       = false
  tags                 = ["mariadb"]

  labels = {
    template = "tf-mariadb"
  }

  metadata {
    startup-script = "${data.template_file.startup.rendered}"
  }

  disk {
    source_image = "debian-cloud/debian-9"
    disk_size_gb = 128
    type         = "pd-standard"
  }

  network_interface {
    subnetwork         = "${data.google_compute_subnetwork.subnetwork1.self_link}"
    subnetwork_project = "${data.google_compute_subnetwork.subnetwork1.project}"
    network_ip = "${google_compute_address.mariadb1.address}"
  }

  service_account {
    email  = "${google_service_account.mariadb.email}"
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

resource "google_compute_instance_group_manager" "mariadb0" {
  provider           = "google-beta"
  project            = "${var.project}"
  name               = "mariadb0"
  base_instance_name = "mariadb0"
  zone               = "${var.zone0}"
  target_size        = 1
  version {
    name              = "v1"
    instance_template = "${google_compute_instance_template.mariadb0.self_link}"
  }
  update_policy {
    minimal_action        = "REPLACE"
    type                  = "PROACTIVE"
    max_unavailable_fixed = "1"
  }
  auto_healing_policies {
    health_check      = "${google_compute_health_check.default.self_link}"
    initial_delay_sec = 300
  }
}

resource "google_compute_instance_group_manager" "mariadb1" {
  provider           = "google-beta"
  project            = "${var.project}"
  name               = "mariadb1"
  base_instance_name = "mariadb1"
  zone               = "${var.zone1}"
  target_size        = 1
  version {
    name              = "v1"
    instance_template = "${google_compute_instance_template.mariadb1.self_link}"
  }
  update_policy {
    minimal_action        = "REPLACE"
    type                  = "PROACTIVE"
    max_unavailable_fixed = "1"
  }
  auto_healing_policies {
    health_check      = "${google_compute_health_check.default.self_link}"
    initial_delay_sec = 300
  }
}