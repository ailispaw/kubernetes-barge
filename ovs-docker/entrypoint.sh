#!/bin/sh

if [ ! -f "/etc/openvswitch/conf.db" ]; then
  ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
fi

ovsdb-server --detach --pidfile \
  --remote=punix:/var/run/openvswitch/db.sock \
  --remote=ptcp:6640 \
  --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
  --log-file=/var/log/openvswitch/ovsdb-server.log \
  /etc/openvswitch/conf.db \

ovs-vsctl --no-wait init

ovs-vswitchd --pidfile --log-file=/var/log/openvswitch/ovs-vswitchd.log
