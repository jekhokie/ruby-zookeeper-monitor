require 'thread'
require 'zk'

class Consumer
  def initialize(ip_port)
    puts "Consumer Initializing..."
    @zk = ZK.new ip_port
    @queue = Queue.new
    @path = '/consumer'
    puts "Consumer Initialized"
  end

  def publish_info_about(data)
    puts "INFORMATION: #{data.inspect}"
  end

  def run
    @zk.register(@path) do |event|
      if event.node_changed? or event.node_created?
        data = @zk.get(@path).first
        publish_info_about data
        @queue.push :got_event
      end
    end

    @zk.stat @path, :watch => true

    while true
    end

    @queue.pop
  ensure
    @zk.close!
  end
end

Consumer.new(ARGV[0]).run
