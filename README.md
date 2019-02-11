# Google Cloud MariaDB HA Cluster Terraform Template

This Terraform template makes it easy to launch a High-Availability MariaDB cluster.


## Usage

### Deploy MariaDB HA Cluster

```
terraform plan
terraform apply
```

### Deprovision MariaDB HA Cluster

```
terraform destroy
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

- /config.tf: Creates a Cloud Storage bucket and uploads a startup script
- /firewall.tf: Creates firewall rules to allow healthcheck, communication within the cluster, and clients on the private network.
- /main.tf: Creates Instance templates and Managed Instance Groups
- /network.tf: Creates Static Private IP and TCP Healthcheck
- /README.md: this file
- /mariadb.sh.tpl: Template for startup script that installs and configures MariaDB
- /service_account.tf: Creates service account and grants permission to write StackDriver Logging and Metrics
- /startup.sh.tpl: Startup script that fetches MariaDB startup script
- /variables.tf: Variables - Edit this file before running apply.


## License

Apache License, Version 2.0

## Disclaimer

This is not an official Google project.

