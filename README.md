# ruby-zookeeper-example

Example producer and consumer for integrating Ruby with the ZooKeeper service.

## Installation

Execute:

    $ bundle install

## Usage

Start an instance of the consumer (terminal instance #1):

    $ ruby consumer.rb 192.168.1.10:2181  # include ip:port of the ZK server location
    # Consumer Initializing...
    # Consumer Initialized

Start an instance of the producer (terminal instance #2):

    $ ruby producer.rb 192.168.1.10:2181  # include ip:port of the ZK server location
    # Producer Initializing...
    # Producer Initialized
    # INFORMATION: "Hello Event" (the same message should be seen in terminal instance #1 for the consumer)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
