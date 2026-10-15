# Fleet Management w/ mgmt

Goals: use mgmt to manage my own systems. 

Spend less time managing and more time doing other work!

# Objectives:

* An inventory/fleet view via web
* Reimaging machines on-demand.
* Virtual machine inventory and management.

# Central Services

TBD:

* Something to monitor health/metrics

# Deployment

First-time setup is not a well-travelled path, but it is roughly:

1. Run etcd, perhaps with `mgmt etcd`
2. Run mgmt, perhaps with `mgmt run empty --no-autoedges --seeds http://localhost:2379`
3. this repo will install a mgmt systemd service, so `mgmt run` can be terminated once that's done.

## Discovery

This system is run on a local network with local machines. It relies on mdns for machine discovery.

One machine must be set as the "nexus" and that role is responsible for running etcd and for advertising itself as 'mgmt.local' over mdns. This advertisement is installed by this repo as the `nexus-mdns` systemd service.


