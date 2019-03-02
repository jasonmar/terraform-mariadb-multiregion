# Google Cloud MariaDB HA Cluster Terraform Template

This Terraform template makes it easy to launch a High-Availability MariaDB cluster.


## Usage

The `admin`, `health_check` and `main` modules can be run separately using `-target` argument.

You should only need to run `admin` and `health_check` once.
To create multiple clusters, edit `cluster_name` in `terraform.tfvars` and apply the `main` module.

### Admin Module: Create GCS Bucket and Service Account

```
terraform plan -target=module.admin
terraform apply -target=module.admin
```


### Health Check Module: Create Health Check 

```
terraform plan -target=module.main
terraform apply -target=module.main
```

### Main Module: Create MariaDB Cluster

```
terraform plan -target=module.main
terraform apply -target=module.main
```


### Deprovision MariaDB HA Cluster

```
terraform destroy -target=module.main
```


## Requirements

### Terraform plugins
- [Terraform](https://www.terraform.io/downloads.html)
- [terraform-provider-google](https://github.com/terraform-providers/terraform-provider-google)
- [terraform-provider-google-beta](https://github.com/terraform-providers/terraform-provider-google-beta)


## Install

### Terraform

You can download the latest Terraform binary here:
- https://releases.hashicorp.com/terraform/

Terraform init will fetch the required plugins
```
terraform init
```


## File structure
The project has the following folders and files:

- [admin/main.tf](admin/main.tf): Creates a Cloud Storage bucket, service account and firewall rules
- [admin/variables.tf](admin/variables.tf): Defines variable types and defaults for admin module
- [health_check/main.tf](health_check/main.tf): Creates healthcheck
- [health_check/variables.tf](health_check/variables.tf): Defines variable types and defaults for health_check module
- [main/main.tf](main/main.tf): Creates startup script, Instance templates and Managed Instance Groups
- [main/variables.tf](main/variables.tf): Defines variable types and defaults for main module
- [main/scripts/mariadb.sh.tpl](main/scripts/mariadb.sh.tpl): Template for script that installs and configures MariaDB
- [main/scripts/startup.sh.tpl](main/scripts/startup.sh.tpl): Startup script that fetches MariaDB script
- LICENSE: Apache License 2.0
- [main.tf](main.tf): Loads variables and calls modules
- README.md: this file
- [terraform.tfvars](terraform.tfvars): Variables - Edit this file and set variable values before running terraform apply.
- [variables.tf](variables.tf): Defines variable types and defaults


## License

Apache License, Version 2.0

## Disclaimer

This is not an official Google project.

