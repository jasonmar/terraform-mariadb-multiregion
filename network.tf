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

data "google_compute_network" "default" {
  project = "${var.xpc_project}"
  name    = "${var.network}"
}

data "google_compute_subnetwork" "subnetwork0" {
  project = "${var.xpc_project}"
  region  = "${var.region0}"
  name    = "${var.subnetwork0}"
}

data "google_compute_subnetwork" "subnetwork1" {
  project = "${var.xpc_project}"
  region  = "${var.region1}"
  name    = "${var.subnetwork1}"
}

resource "google_compute_address" "mariadb0" {
  project      = "${var.project}"
  name         = "mariadb0"
  subnetwork   = "${data.google_compute_subnetwork.subnetwork0.self_link}"
  address_type = "INTERNAL"
  region       = "${var.region0}"
}

resource "google_compute_address" "mariadb1" {
  project      = "${var.project}"
  name         = "mariadb1"
  subnetwork   = "${data.google_compute_subnetwork.subnetwork1.self_link}"
  address_type = "INTERNAL"
  region       = "${var.region1}"
}

resource "google_compute_health_check" "default" {
  project             = "${var.project}"
  name                = "mariadb"
  timeout_sec         = 2
  check_interval_sec  = 8
  healthy_threshold   = 1
  unhealthy_threshold = 3

  tcp_health_check {
    port = "3306"
  }
}