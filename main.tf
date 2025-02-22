locals {
  firewall_name = format("%s-%s", var.project, var.vpc_name)
}

resource "google_compute_network" "vpc_network" {
  project                 = var.project
  name                    = var.vpc_name
  auto_create_subnetworks = false
  mtu                     = var.mtu
}

resource "google_compute_subnetwork" "subnetworks" {
  for_each      = { for subnet in var.subnetworks : subnet.name => subnet }
  name          = each.value.name
  project       = var.project
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "firewall" {
  name    = local.firewall_name
  project = var.project
  network = google_compute_network.vpc_network.id

  dynamic "allow" {
    for_each = var.firewall_allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.port
    }
  }

}
