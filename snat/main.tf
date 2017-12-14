resource "openstack_compute_instance_v2" "snat" {
  name = "snat"
  image_name = "${var.image_name}"
  flavor_name = "${var.flavor}"
  network { 
    uuid = "${openstack_networking_network_v2.snat.id}"
  }
  user_data = "${file("cloud-init.yaml")}"
}

resource "openstack_networking_network_v2" "snat" {
  name = "snat"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "snat" {
  name = "snat"
  network_id = "${openstack_networking_network_v2.snat.id}"
  cidr = "192.168.1.0/24"
  ip_version = 4
  enable_dhcp = true
}

resource "openstack_networking_router_v2" "snat" {
  name = "snat"
  external_gateway = "${var.public_net_id}"
} 

resource "openstack_networking_router_interface_v2" "snat_router_net_itf" {
  router_id = "${openstack_networking_router_v2.snat.id}"
  subnet_id = "${openstack_networking_subnet_v2.snat.id}"
}

output "Doc           " {
  value = "A vm on a SNAT network. This VM redirects ping output to console-log."
}

output "To check pings" {
  value = "while true; do openstack console log show --lines 20 ${openstack_compute_instance_v2.snat.id}; sleep 10; echo; done"
}
