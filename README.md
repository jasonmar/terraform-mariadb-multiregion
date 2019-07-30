# Google Cloud MariaDB HA Cluster Terraform Template

This Terraform template makes it easy to launch a High-Availability MariaDB cluster.


## Usage

The `admin`, `health_check` and `main` modules can be run separately using `-target` argument.

You should only need to run `admin` and `health_check` once.
To create multiple clusters, edit `cluster_name` in `terraform.tfvars` and apply the `main` module.


### Generating SSL Keys and Certificates

You will need to run [main/ssl/genkeys.sh](main/ssl/genkeys.sh) to generate keys certificates that are needed to enable secure transport for replication and client connections.

```sh
cd main/ssl
./genkeys.sh
```

### Project Setup

You will need to enable the APIs used by terraform.

```sh
for svc in compute iam storage-api; do
  gcloud services enable $svc.googleapis.com
done
```

### Admin Module: Create GCS Bucket and Service Account

```sh
terraform plan -target=module.admin
terraform apply -target=module.admin
```


### Health Check Module: Create Health Check 

```sh
terraform plan -target=module.health_check
terraform apply -target=module.health_check
```

### Main Module: Create MariaDB Cluster

```sh
terraform plan -target=module.main
terraform apply -target=module.main
```

### Making updates

After making changes to a script or instance template, modify `template_version` in [terraform.tfvars](terraform.tfvars) and run `terraform plan` and `terraform apply` to create a new instance template. Use Instance group Rolling Update with Update mode set to `Proactive` or Rolling Restart/Replace with operation set to `Replace` to replace the instance immediately with the new template.

### Deprovision MariaDB HA Cluster

```sh
terraform destroy -target=module.main
```

## Network

### Ports

- 3306 mysql database port
- 4567 wsrep each node listens for SSL connection
- 4444 rsync sst message initiates rsync transfer

### Choosing Regions and Zones

For a multi-regional deployment, select two zones in one region and two zones in another region, with the arbitrator node in a third region.

For a regional deployment, select two zones to contain two nodes each and deploy the arbitrator node to a third zone.


## Verify Replication

```sql
SHOW MASTER STATUS;
SHOW SLAVE STATUS;
```

## Troubleshooting

```sh
journalctl -xe | cat
```

```sql
SHOW VARIABLES LIKE 'wsrep%';
```

Check cluster size 

```sql
SHOW STATUS LIKE 'wsrep_cluster_size';
```

Replication status

```sql
SHOW STATUS LIKE 'wsrep%';
```


## Template Design

`label`s can be used from StackDriver to filter metrics.

`metadata` can be accessed from within the instance.

`service account` can be used to create targeted firewall rules.

`tag`s can be used to control network traffic using routes and firewall rules.

`auto_increment_increment` controls the interval between successive column values.
`auto_increment_offset` determines the starting point for the AUTO_INCREMENT column value.





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
```sh
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


## Client Connection String

[JDBC](https://mariadb.com/kb/en/library/failover-and-high-availability-with-mariadb-connector-j/)

```
jdbc:mysql:replication://node0,node1,node2,node3/[database][?<k>=<v>[&<k>=<v>]...]
```

[Python SQLAlchemy](https://docs.sqlalchemy.org/en/latest/dialects/mysql.html) with [mysqlclient-python](https://github.com/PyMySQL/mysqlclient-python)

```
mysql+mysqldb://username:password@node0,node1,node2,node3:port/[database]
```

[Python](https://dev.mysql.com/doc/connector-python/en/connector-python-connectargs.html)



[ODBC](https://mariadb.com/kb/en/library/about-mariadb-connector-odbc/)

## References

[Galera Cluster Documentation](http://galeracluster.com/documentation-webpages/)
[Galera Arbitrator](http://galeracluster.com/documentation-webpages/arbitrator.html)
[garbd man page](https://manpages.debian.org/stretch/galera-arbitrator-3/garbd.8.en.html)
[Multi Source Replication](https://mariadb.com/kb/en/library/multi-source-replication/)
[State Snapshot Transfer](https://mariadb.com/kb/en/library/introduction-to-state-snapshot-transfers-ssts/)
[Galera System Variable](https://mariadb.com/kb/en/library/galera-cluster-system-variables/)
[Galera Parameters](http://galeracluster.com/documentation-webpages/galeraparameters.html)

## License

Apache License, Version 2.0

## Disclaimer

This is not an official Google project.

