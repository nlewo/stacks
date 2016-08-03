resource "openstack_compute_keypair_v2" "rj45" {
  name = "rj45-terraform"
  public_key = "${file("${var.ssh_key_file}.pub")}"
  region = "${var.region}"
}

resource "openstack_compute_servergroup_v2" "backend" {
  name = "lb_group_backend"
  policies = ["anti-affinity"]
  region = "${var.region}"
} 

resource "openstack_compute_instance_v2" "backend" {
  region = "${var.region}"
  name = "lb_backend_${count.index}"
  image_name = "${var.image_name}"
  flavor_id = "${var.flavor_id}"
  network { 
    uuid = "${openstack_networking_network_v2.backend.id}"
    floating_ip = "${element(openstack_networking_floatingip_v2.backend.*.address, count.index)}"
  }
  metadata {
    groups = "lb_backend"
  }
  key_pair = "${var.key_pair}"
  security_groups = ["${openstack_compute_secgroup_v2.backend.name}"]
  count = "${var.instances.backend}"
  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.backend.id}"
  }
}

resource "openstack_networking_network_v2" "backend" {
  name = "lbaas-backend"
  admin_state_up = "true"
  region = "${var.region}"
}

resource "openstack_networking_subnet_v2" "backend" {
  name = "lbaas-backend"
  network_id = "${openstack_networking_network_v2.backend.id}"
  cidr = "10.22.22.0/24"
  ip_version = 4
  region = "${var.region}"
  enable_dhcp = true
}

resource "openstack_networking_network_v2" "vip" {
  name = "lbaas-vip"
  admin_state_up = "true"
  region = "${var.region}"
}

resource "openstack_networking_subnet_v2" "vip" {
  name = "lbaas-vip"
  network_id = "${openstack_networking_network_v2.vip.id}"
  cidr = "10.55.55.0/24"
  ip_version = 4
  region = "${var.region}"
}

resource "openstack_lb_pool_v1" "backend" {
  name = "lb_pool_backend"
  protocol = "TCP"
  subnet_id = "${openstack_networking_subnet_v2.backend.id}"
  lb_method = "ROUND_ROBIN"
  region = "${var.region}"
}

resource "openstack_lb_vip_v1" "vip" {
  name = "lb_vip"
  subnet_id = "${openstack_networking_subnet_v2.backend.id}"
  protocol = "TCP"
  port = 443
  pool_id = "${openstack_lb_pool_v1.backend.id}"
  region = "${var.region}"
}

resource "openstack_networking_floatingip_v2" "vip" {
  region = "${var.region}"
  pool = "public"
  port_id = "${openstack_lb_vip_v1.vip.port_id}"
}

resource "openstack_networking_floatingip_v2" "backend" {
  region = "${var.region}"
  pool = "public"
  count = "${var.instances.backend}"
}

resource "openstack_lb_member_v1" "backend" {
  pool_id = "${openstack_lb_pool_v1.backend.id}"
  address = "${element(openstack_compute_instance_v2.backend.*.network.0.fixed_ip_v4, count.index)}"
  port = 443
  count = "${var.instances.backend}"
  region = "${var.region}"
}

resource "openstack_compute_secgroup_v2" "backend" {
  region = "${var.region}"
  name = "lb_secgroup_backend"
  description = "lb_secgroup_backend"
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
    from_group_id = ""
  }
  rule {
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
    from_group_id = ""
  }
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}
