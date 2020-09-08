resource "google_compute_firewall" "vpc_firewall_ex" {
  name    = "external-rule"
  network = var.network
  description = "allow access through ssh and http"

  allow {
  protocol = "tcp"
  ports = ["80", "22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = var.tags
  }

resource "google_compute_instance" "ldap-server" {
 name    = var.name
 machine_type = var.machine_type
 zone     = var.zone
 tags     = var.tags

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
metadata_startup_script = "${file(var.script)}"
}

output "External_IP" {
value = "http://${google_compute_instance.ldap-server.network_interface.0.access_config.0.nat_ip}/ldapadmin/"
}

