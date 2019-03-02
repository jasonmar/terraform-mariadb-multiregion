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
  project = "${var.project}"
  version = ">= 2.1.0, <= 2.2.0"
}

module "main" {
  source            = "main/"
  cluster_name      = "${var.cluster_name}"
  databases         = "${var.databases}"
  project           = "${var.project}"
  region            = "${var.region}"
  zone              = "${var.zone}" 
  xpn_project       = "${var.xpn_project}"
  network           = "${var.network}"
  subnetwork        = "${var.subnetwork}"
  health_check      = "${var.health_check}"
  service_account   = "${var.service_account}"
  config_bucket     = "${var.config_bucket}"
  instance_type     = "${var.instance_type}"
  disk_size_gb      = "${var.disk_size_gb}"
  disk_type         = "${var.disk_type}"
  client_ip_range   = "${var.client_ip_range}"
  pass              = "${var.pass}"
  replpass          = "${var.replpass}"
  instance_count    = "${var.instance_count}"
}

module "admin" {
  source            = "admin/"
  project           = "${var.project}"
  bucket_region     = "${var.bucket_region}"
  xpn_project       = "${var.xpn_project}"
  network           = "${var.network}"
  service_account   = "${var.service_account}"
  config_bucket     = "${var.config_bucket}"
  client_ip_range   = "${var.client_ip_range}"
}

module "health_check" {
  source       = "health_check/"
  project      = "${var.project}"
  health_check = "${var.health_check}"
}
