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
# LDAP-client                                                 #
###############################################################

resource "google_compute_instance" "ldap-client" {
 name    = var.client_name
 machine_type = var.machine_type
 zone     = var.zone
 tags     = var.client_tags

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
metadata_startup_script = templatefile("./startup-client.sh", {server_ip = google_compute_instance.ldap-server.network_interface.0.network_ip})
}

output "Client_External_IP" {
value = "ssh -i <your key> my_user@${google_compute_instance.ldap-client.network_interface.0.access_config.0.nat_ip}"
}

###############################################################
# LDAP-server                                                 #
###############################################################

resource "google_compute_instance" "ldap-server" {
 name    = var.server_name
 machine_type = var.machine_type
 zone     = var.zone
 tags     = var.server_tags

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
 metadata_startup_script = "${file(var.server_script)}"
}
