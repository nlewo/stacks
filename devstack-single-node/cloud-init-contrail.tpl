#cloud-config

package_update: true
package_upgrade: true

packages:
  - git
  - emacs23-nox
  - make
  - libc6-dev
  - haproxy=1.5.14-1ubuntu0.15.10.1~ubuntu14.04.1
  
runcmd:
  - su cloud -c "tmux new-session -d"
  - su cloud -c "tmux send-keys -t 0 'bash -x -e /opt/run.sh' enter"

write_files:
-   path: /opt/run.sh
    permissions: 0775
    content: |
      #!/usr/bin/env bash
      cd ~/ && git clone https://github.com/openstack-dev/devstack.git
      cd devstack
      git checkout stable/mitaka
      cp /opt/local.conf .
      ./stack.sh

-   path: /opt/local.conf
    permissions: 0664
    content: |
        [[local|localrc]]
        SERVICE_TOKEN=azertytoken
        ADMIN_PASSWORD=contrail123
        MYSQL_PASSWORD=stackdb
        RABBIT_PASSWORD=stackqueue
        SERVICE_PASSWORD=$ADMIN_PASSWORD
        LOGFILE=$DEST/logs/stack.sh.log
        LOGDAYS=2
        SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
        SWIFT_REPLICAS=1
        SWIFT_DATA_DIR=$DEST/data

        enable_service tempest

        disable_service ui-jobs ui-webs

        enable_plugin contrail https://github.com/zioc/contrail-devstack-plugin.git
        enable_plugin neutron-lbaas https://github.com/openstack/neutron-lbaas.git stable/mitaka

        # CONTRAIL_REPO=https://github.com/eonpatapon/contrail-vnc.git
        CONTRAIL_BRANCH=R3.2

        SCONS_JOBS=$(lscpu -p | grep -cve '^#')

        RECLONE=no

        VHOST_INTERFACE_NAME=eth1
        VHOST_INTERFACE_CIDR=10.0.0.1/24
        VHOST_INTERFACE_IP=10.0.20.1
        DEFAULT_GW=10.0.0.254
        
        [[post-config|$NEUTRON_CONF]]
        [DEFAULT]
        # service_plugins = neutron_plugin_contrail.plugins.opencontrail.loadbalancer.plugin.LoadBalancerPlugin
        service_plugins = 
        api_extensions_path = extensions:/opt/stack/contrail/openstack/neutron_plugin/neutron_plugin_contrail/extensions:/opt/stack/neutron-lbaas/neutron_lbaas/extensions
        [quotas]
        quota_driver = neutron_plugin_contrail.plugins.opencontrail.quota.driver.QuotaDriver

        [service_providers]
        service_provider = LOADBALANCER:Haproxy:neutron_plugin_contrail.plugins.opencontrail.loadbalancer.driver.OpencontrailLoadbalancerDriver:default

        [keystone_authtoken]
        auth_type =
        
        [[post-config|$NOVA_CONF]]
        [libvirt]
        vif_driver = nova_contrail_vif.contrailvif.VRouterVIFDriver
        virt_type = qemu
