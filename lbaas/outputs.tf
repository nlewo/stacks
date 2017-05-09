output "Backend" {
  value = ["${openstack_networking_floatingip_v2.backend.*.address}"]
}

output "VIP" {
  value = "${openstack_networking_floatingip_v2.vip.address}"
}
