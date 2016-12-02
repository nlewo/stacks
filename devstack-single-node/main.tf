resource "openstack_networking_floatingip_v2" "master" {
  region = "${var.region}"
  pool = "public"
}

resource "openstack_networking_network_v2" "net_simple" {
  name = "net_simple"
  admin_state_up = "true"
  region = "${var.region}"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name = "subnet"
  network_id = "${openstack_networking_network_v2.net_simple.id}"
  cidr = "10.22.22.0/24"
  ip_version = 4
  region = "${var.region}"
  enable_dhcp = true
}

resource "openstack_compute_secgroup_v2" "ssh" {
  name = "ssh"
  description = "ssh"
  region = "${var.region}"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}


resource "openstack_compute_instance_v2" "master" {
  name = "${var.name}"
  region = "${var.region}"
  image_name = "${var.image_name}"
  flavor_id = "${var.flavor_id}"
  network { 
    port = "${openstack_networking_port_v2.master.id}"
    floating_ip = "${openstack_networking_floatingip_v2.master.address}"
  }
  key_pair = "${var.key_pair_name}"
  user_data = "${template_file.master.rendered}"
}

resource "template_file" "master" {
  template = "${file("cloud-init-contrail.tpl")}"
}

resource "openstack_networking_port_v2" "master" {
  region = "${var.region}"
  name = "${var.name}"
  network_id = "${openstack_networking_network_v2.net_simple.id}"
  admin_state_up = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.ssh.id}"]
    fixed_ip {
      subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
    }
}
