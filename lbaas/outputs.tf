output "Backend" {
  value = "${join(\"\", formatlist(\"\nssh -i %s.private cloud@%s\", var.ssh_key_file, openstack_networking_floatingip_v2.backend.*.address))}"
}

output "VIP" {
  value = "${openstack_networking_floatingip_v2.vip.address}"
}
