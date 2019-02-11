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

variable "project" {
  default = "retail-poc-demo"
}

variable "region0" {
  default = "us-east1"
}

variable "region1" {
  default = "us-east1"
}

variable "zone0" {
  default = "us-east1-b" 
}

variable "zone1" {
  default = "us-east1-b" 
}

variable "xpc_project" {
  default = "retail-poc-demo"
}

variable "network" {
  default = "data"
}

variable "subnetwork0" {
  default = "data"
}

variable "subnetwork1" {
  default = "data"
}

variable "service_account" {
  default = "mariadb2"
}

variable "config_bucket" {
  default = "mariadb_conf_20190211"
}

# n1-highmem-2   2 vCPUs 13 GB
# n1-highmem-4   4 vCPUs 26 GB
# n1-highmem-8   8 vCPUs 52 GB
# n1-highmem-16  16 vCPUs 104 GB
# n1-highmem-32  32 vCPUs 208 GB
variable "instance_type" {
  default = "n1-highmem-2"
}

variable "client_ip_range" {
  default = "10.0.0.0/8"
}

variable "pass" {
  default = "changeit"
}