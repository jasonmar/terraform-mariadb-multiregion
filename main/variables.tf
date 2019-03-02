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

variable "cluster_name" { default = "cluster1" }
variable "project" { default = "" }
variable "xpn_project" { default = "" }
variable "network" { default = "" }
variable "service_account" { default = "" }
variable "config_bucket" { default = "" }
variable "instance_type" { default = "" }
variable "client_ip_range" { default = "10.0.0.0/8" }
variable "pass" { default = "" }
variable "replpass" { default = "" }
variable "instance_count" { default = "" }
variable "disk_size_gb" { default = 256 }
variable "disk_type" { default = "pd-standard" }
variable "health_check" { default = "mariadb" }
variable "databases" { default = "testdb" }

# Map Variables with one record per instance
variable "region" { default = {} }
variable "zone" { default = {} }
variable "subnetwork" { default = {} }
