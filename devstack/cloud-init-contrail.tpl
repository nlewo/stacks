#cloud-config

package_update: true
package_upgrade: true

packages:
  - git
  - emacs23-nox
  - make
  - libc6-dev
  
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

        enable_plugin contrail https://github.com/zioc/contrail-devstack-plugin.git
        enable_plugin neutron-lbaas https://github.com/openstack/neutron-lbaas.git stable/mitaka

        CONTRAIL_REPO=https://github.com/eonpatapon/contrail-vnc.git
        CONTRAIL_BRANCH=R2.21-cloudwatt
        SCONS_JOBS=$(lscpu -p | grep -cve '^#')

        
        [[post-config|$NEUTRON_CONF]]
        [DEFAULT]
        service_plugins = neutron_plugin_contrail.plugins.opencontrail.loadbalancer.plugin.LoadBalancerPlugin
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
