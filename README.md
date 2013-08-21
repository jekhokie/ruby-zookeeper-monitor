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

The usage of this project is best performed in multiple (side-by-side) terminal windows.

---

Start an instance of the Service Monitor (terminal instance #1):

    $ ruby lib/service_monitor.rb

    # Service Monitor Initializing...    [ OK ]

Start the simulator (terminal instance #2):

    $ ruby lib/simulator.rb

    # Simulator Thread Initialized for Service with IP: 10.0.24.2
    # Simulator Thread Initialized for Service with IP: 10.0.24.3
    # Simulator Thread Initialized for Service with IP: 10.0.24.4
    # Simulator Thread Initialized for Service with IP: 10.0.24.5
    # Simulator Thread Initialized for Service with IP: 10.0.24.6
    ...

Watch the Service Monitor track the services as they come online/register and leave/unregister (terminal instance #1):

    ...
    # Service IPs Online: 10.0.24.10, 10.0.24.3, 10.0.24.4, 10.0.24.12, 10.0.24.7, 10.0.24.8, 10.0.24.9
    # Service(s) with IP 10.0.24.9 Un-Registered
    # Service IPs Online: 10.0.24.10, 10.0.24.3, 10.0.24.4, 10.0.24.12, 10.0.24.7, 10.0.24.8
    # ============================================================================
    # SERVICE (10.0.24.10) | Processing (8962) | Capacity remaining (1038)
    # SERVICE (10.0.24.3) | Processing (8109) | Capacity remaining (1891)
    # SERVICE (10.0.24.4) | Processing (9913) | Capacity remaining (87)
    # SERVICE (10.0.24.12) | Processing (7229) | Capacity remaining (2771)
    # SERVICE (10.0.24.7) | Processing (6157) | Capacity remaining (3843)
    # SERVICE (10.0.24.8) | Processing (4948) | Capacity remaining (5052)
    # ============================================================================
    # Service(s) with IP 10.0.24.13 Registered
    # Service IPs Online: 10.0.24.10, 10.0.24.3, 10.0.24.4, 10.0.24.12, 10.0.24.7, 10.0.24.13, 10.0.24.8
    # Service(s) with IP 10.0.24.3 Un-Registered
    # Service IPs Online: 10.0.24.10, 10.0.24.4, 10.0.24.12, 10.0.24.7, 10.0.24.13, 10.0.24.8
    # Service(s) with IP 10.0.24.4 Un-Registered
    # Service IPs Online: 10.0.24.10, 10.0.24.12, 10.0.24.7, 10.0.24.13, 10.0.24.8
    # ============================================================================
    # SERVICE (10.0.24.10) | Processing (8962) | Capacity remaining (1038)
    # SERVICE (10.0.24.12) | Processing (7229) | Capacity remaining (2771)
    # SERVICE (10.0.24.7) | Processing (6157) | Capacity remaining (3843)
    # SERVICE (10.0.24.13) | Processing (9671) | Capacity remaining (329)
    # SERVICE (10.0.24.8) | Processing (475) | Capacity remaining (9525)
    # ============================================================================
    # Service(s) with IP 10.0.24.13 Un-Registered
    # Service IPs Online: 10.0.24.10, 10.0.24.12, 10.0.24.7, 10.0.24.8
    # ============================================================================
    # SERVICE (10.0.24.10) | Processing (8901) | Capacity remaining (1099)
    # SERVICE (10.0.24.12) | Processing (1358) | Capacity remaining (8642)
    # SERVICE (10.0.24.7) | Processing (7357) | Capacity remaining (2643)
    # SERVICE (10.0.24.8) | Processing (4639) | Capacity remaining (5361)
    # ============================================================================
    ...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
