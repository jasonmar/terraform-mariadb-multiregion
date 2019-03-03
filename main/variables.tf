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

variable "cluster_name" { default = "" }
variable "project" { default = "" }
variable "xpn_project" { default = "" }
variable "service_account" { default = "" }
variable "config_bucket" { default = "" }
variable "instance_type" { default = "" }
variable "client_ip_range" { default = "" }
variable "pass" { default = "" }
variable "replpass" { default = "" }
variable "statspass" { default = "" }
variable "instance_count" { default = "" }
variable "disk_size_gb" { default = 256 }
variable "disk_type" { default = "" }
variable "health_check" { default = "" }
variable "databases" { default = "" }
variable "template_version" { default = "" }
variable "garb_instance_type" { default = "" }
variable "garb_zone" { default = "" }
variable "garb_region" { default = "" }
variable "garb_subnetwork" { default = "" }

# Map Variables with one record per instance
variable "region" { default = {} }
variable "zone" { default = {} }
variable "subnetwork" { default = {} }
