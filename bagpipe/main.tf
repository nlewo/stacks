resource "openstack_compute_keypair_v2" "rj45" {
  name = "rj45"
  public_key = "${file("${var.ssh_key_file}.pub")}"
  region = "${var.region}"
}

resource "openstack_networking_floatingip_v2" "master" {
  region = "${var.region}"
  pool = "public"
}

resource "openstack_networking_floatingip_v2" "slave" {
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

resource "openstack_networking_secgroup_v2" "vpn" {
  name = "vpn"
  description = "vpn"
  region = "${var.region}"
}

resource "openstack_networking_secgroup_rule_v2" "bgp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 179
  port_range_max = 179
  remote_group_id = "${openstack_networking_secgroup_v2.vpn.id}"
  security_group_id = "${openstack_networking_secgroup_v2.vpn.id}"
}

resource "openstack_networking_secgroup_rule_v2" "all" {
  direction = "ingress"
  ethertype = "IPv4"
  remote_group_id = "${openstack_networking_secgroup_v2.vpn.id}"
  security_group_id = "${openstack_networking_secgroup_v2.vpn.id}"
}

# resource "openstack_networking_secgroup_rule_v2" "gre" {
#   direction = "ingress"
#   ethertype = "IPv4"
#   protocol = "gre" # 47 # This doesn't work
#   remote_group_id = "${openstack_networking_secgroup_v2.vpn.id}"
#   security_group_id = "${openstack_networking_secgroup_v2.vpn.id}"
# }


resource "openstack_compute_instance_v2" "master" {
  name = "master"
  region = "${var.region}"
  image_name = "${var.image_name}"
  flavor_id = "${var.flavor_id}"
  network { 
    port = "${openstack_networking_port_v2.master.id}"
    floating_ip = "${openstack_networking_floatingip_v2.master.address}"
  }
  key_pair = "${openstack_compute_keypair_v2.rj45.name}"
  user_data = "${template_file.master.rendered}"
}

resource "openstack_compute_instance_v2" "slave" {
  name = "slave"
  region = "${var.region}"
  image_name = "${var.image_name}"
  flavor_id = "${var.flavor_id}"
  network { 
    port = "${openstack_networking_port_v2.slave.id}"
    floating_ip = "${openstack_networking_floatingip_v2.slave.address}"
  }
  key_pair = "${openstack_compute_keypair_v2.rj45.name}"
  user_data = "${template_file.slave.rendered}"
}

resource "template_file" "slave" {
  template = "${file("cloud-init.tpl")}"
    vars {
      env = "BAGPIPE_BGP_PEERS=${openstack_networking_port_v2.master.fixed_ip.0.ip_address} CIDR=20.0.0.0/24"
    }
}

resource "template_file" "master" {
  template = "${file("cloud-init.tpl")}"
    vars {
      env = "BAGPIPE_BGP_PEERS=${openstack_networking_port_v2.master.fixed_ip.0.ip_address} FAKERR=True CIDR=10.0.0.0/24"
    }
}



resource "openstack_networking_port_v2" "master" {
  region = "${var.region}"
  name = "master"
  network_id = "${openstack_networking_network_v2.net_simple.id}"
  admin_state_up = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.ssh.id}", "${openstack_networking_secgroup_v2.vpn.id}"]
    fixed_ip {
      subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
    }
}

resource "openstack_networking_port_v2" "slave" {
  region = "${var.region}"
  name = "slave"
  network_id = "${openstack_networking_network_v2.net_simple.id}"
  admin_state_up = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.ssh.id}", "${openstack_networking_secgroup_v2.vpn.id}"]
    fixed_ip {
      subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
    }
}
