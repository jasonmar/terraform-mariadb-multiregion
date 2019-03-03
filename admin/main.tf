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

resource "google_service_account" "default" {
  project      = "${var.project}"
  account_id   = "${var.service_account}"
  display_name = "${var.service_account}"
}

resource "google_project_iam_member" "logs" {
  project = "${var.project}"
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "metrics" {
  project = "${var.project}"
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_compute_firewall" "healthcheck" {
  project = "${var.xpn_project}"
  name    = "mariadb-healthcheck-${var.service_account}"
  network = "${var.network}"
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  source_ranges  = ["35.191.0.0/16","130.211.0.0/22"]
  target_service_accounts = ["${google_service_account.default.email}"]
}

resource "google_compute_firewall" "client" {
  project = "${var.xpn_project}"
  name    = "mariadb-client-${var.service_account}"
  network = "${var.network}"
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  source_ranges  = ["${var.client_ip_range}"]
  target_service_accounts = ["${google_service_account.default.email}"]
}

resource "google_compute_firewall" "cluster" {
  project = "${var.xpn_project}"
  name    = "mariadb-cluster-${var.service_account}"
  network = "${var.network}"
  allow {
    protocol = "tcp"
    ports    = ["3306","4567","4444"]
  }
  source_service_accounts = ["${google_service_account.default.email}"]
  target_service_accounts = ["${google_service_account.default.email}"]
}

resource "google_storage_bucket" "config" {
  project       = "${var.project}"
  name          = "${var.config_bucket}"
  storage_class = "MULTI_REGIONAL"
  location      = "${var.bucket_region}"
}

resource "google_storage_bucket_iam_binding" "config" {
  bucket  = "${google_storage_bucket.config.name}"
  role    = "roles/storage.objectViewer"
  members = ["serviceAccount:${google_service_account.default.email}"]
}
