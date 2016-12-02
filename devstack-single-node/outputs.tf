output "master" {
    value = "ssh cloud@${openstack_networking_floatingip_v2.master.address}"
}
