# ruby-zookeeper-monitor

Example services monitor and corresponding simulator using Ruby and ZooKeeper.

## Background

Often times, it is beneficial to allow services to publish their presence in order for other
services to subscribe/connect with them. This project simulates multiple services 'subscribing'
and 'unsubscribing' using ephemeral nodes in ZooKeeper. The Service Monitor instance watches
for subscriptions/un-subscribes, and publishes information about which services are currently
available, subscribing, and un-subscribing.

## Installation

### Apache ZooKeeper:

Reference the Apache ZooKeeper website on how to install/start the ZooKeeper service:

  http://zookeeper.apache.org/

### Ruby Gems:

Set up the required Ruby Gems:

    $ bundle install

### Configuration:

Update the following file to reflect the configuration for your environment:

    $ vim config/settings

## Usage

Start an instance of the Service Monitor (terminal instance #1):

    $ ruby lib/service_monitor.rb 192.168.1.10:2181  # include ip:port of the ZK server location

    # Service Monitor Initializing...    [ OK ]

Start the simulator (terminal instance #2):

    $ ruby lib/simulator.rb 192.168.1.10:2181  # include ip:port of the ZK server location

    # Simulator Thread Initialized for Service ID: 0
    # Simulator Thread Initialized for Service ID: 1
    # Simulator Thread Initialized for Service ID: 2
    # Simulator Thread Initialized for Service ID: 3
    # Simulator Thread Initialized for Service ID: 4
    ...

Watch the Service Monitor track the services as they come online/register and leave/unregister:

    # Service(s) with ID 0 registered
    # SERVICES IDS ONLINE: 0
    # Service(s) with ID 1 registered
    # SERVICES IDS ONLINE: 1
    # Service(s) with ID 3,2 registered
    # SERVICES IDS ONLINE: 3,2,1
    # Service(s) with ID 7,5,4 registered
    # SERVICES IDS ONLINE: 3,2,1,7,5,4
    # Service(s) with ID 4,8 unregistered
    # SERVICES IDS ONLINE: 3,2,10,7,11
    # Service(s) with ID 2 unregistered
    # SERVICES IDS ONLINE: 3,10,7,11
    ...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
