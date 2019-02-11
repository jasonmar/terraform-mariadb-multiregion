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

resource "google_compute_firewall" "healthcheck" {
  project = "${var.project}"
  name    = "healthcheck"
  network = "${data.google_compute_network.default.name}"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges  = ["35.191.0.0/16","130.211.0.0/22"]
  target_service_accounts = ["${google_service_account.mariadb.email}"]
}

resource "google_compute_firewall" "mariadb" {
  project = "${var.project}"
  name    = "mariadb"
  network = "${data.google_compute_network.default.name}"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_service_accounts = ["${google_service_account.mariadb.email}"]
  target_service_accounts = ["${google_service_account.mariadb.email}"]
}

resource "google_compute_firewall" "client" {
  project = "${var.project}"
  name    = "mariadb-client"
  network = "${data.google_compute_network.default.name}"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges  = ["${var.client_ip_range}"]
  target_service_accounts = ["${google_service_account.mariadb.email}"]
}