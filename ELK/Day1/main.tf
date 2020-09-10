###############################################################
# Firewall rules                                              #
###############################################################

resource "google_compute_firewall" "vpc_firewall_ex" {
  name    = "external-rule"
  network = var.network
  description = "allow access through ssh and http"

  allow {
  protocol = "tcp"
  ports = ["22" , "5601"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = var.kibana_tags
  }

resource "google_compute_firewall" "vpc_firewall_int1" {
  name    = "internal-rule1"
  network = var.network
  description = "allow access in internal network"
 allow {
 ports = ["0-65535"]
 protocol = "tcp"
 }
 allow {
 ports = ["0-65535"]
 protocol = "udp"
 }
 source_tags = var.kibana_tags
 target_tags = var.tomcat_tags
 }

###############################################################
# Cloud NAT                                                   #
###############################################################

resource "google_compute_router" "router" {
  name    = "my-router"
  region  = var.region
  network = var.network
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

}

###############################################################
# Elasticsearch and Kibana                                    #
###############################################################

resource "google_compute_instance" "kibana" {
 name    = var.kibana_name
 machine_type = var.machine_type
 zone     = var.zone
 tags     = var.kibana_tags

 boot_disk {
   initialize_params {
       image = var.image
       size  = var.size
       type  = var.disk_type
    }
  }

network_interface {
    network = var.network
    access_config {
    }
  }
metadata_startup_script = "${file(var.kibana_script)}"
}


output "Kibana_IP" {
  value = "http://${google_compute_instance.kibana.network_interface.0.access_config.0.nat_ip}:5601/"
}

###############################################################
# Tomcat                                                      #
###############################################################

resource "google_compute_instance" "tomcat" {
 name    = var.tomcat_name
 machine_type = var.machine_type
 zone     = var.zone
 tags     = var.tomcat_tags

 boot_disk {
   initialize_params {
       image = var.image
       size  = var.size
       type  = var.disk_type
    }
  }

network_interface {
    network = var.network
  }
 metadata_startup_script = "${file(var.tomcat_script)}"
}
