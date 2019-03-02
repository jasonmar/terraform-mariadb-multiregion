project         = "myproject"
xpn_project     = "myproject"
network         = "default"

service_account = "mariadb"
config_bucket   = "mariadb_config"
health_check    = "mariadb"
instance_type   = "n1-standard-2"
disk_size_gb    = 128
disk_type       = "pd-standard"

cluster_name    = "c0"
databases       = "testdb airflow hive" # space separated
pass            = "changeit"
replpass        = "changeit"
client_ip_range = "10.0.0.0/8"

# region, zone, subnetwork are maps of size instance_count
instance_count  = 2
region = {
  "0" = "us-east1"
  "1" = "us-east1"
}
zone = {
  "0" = "us-east1-b"
  "1" = "us-east1-b"
}
subnetwork = {
  "0" = "data"
  "1" = "data"
}
