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

resource "google_storage_bucket" "config" {
  project       = "${var.project}"
  name          = "${var.config_bucket}"
  storage_class = "REGIONAL"
  location      = "us-east1"
}

resource "google_storage_bucket_iam_binding" "config" {
  bucket      = "${google_storage_bucket.config.name}"
  role        = "roles/storage.objectViewer"
  members = ["serviceAccount:${google_service_account.mariadb.email}"]
}

data "template_file" "config" {
  template = "${file("mariadb.sh.tpl")}"
  vars = {
    mariadb0 = "${google_compute_address.mariadb0.address}"
    mariadb1 = "${google_compute_address.mariadb1.address}"
    pass = "${var.pass}"
  }
}

resource "google_storage_bucket_object" "config" {
  name    = "mariadb.sh"
  content = "${data.template_file.config.rendered}"
  bucket  = "${google_storage_bucket.config.name}"
}

data "template_file" "startup" {
  template = "${file("startup.sh.tpl")}"
  vars = {
    script_path = "gs://${google_storage_bucket.config.name}/${google_storage_bucket_object.config.name}"
  }
}
