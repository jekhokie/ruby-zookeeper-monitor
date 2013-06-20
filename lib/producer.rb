require 'thread'
require 'zk'

class Producer
  def initialize(ip_port)
    puts "Producer Initializing..."
    @zk = ZK.new ip_port
    @queue = Queue.new
    @path = '/consumer'
    puts "Producer Initialized"
  end

  def publish_info_about(data)
    puts "INFORMATION: #{data.inspect}"
  end

  def run
    begin
      @zk.delete @path
    rescue ZK::Exceptions::NoNode
    end

    @zk.watcher.register(@path) do |event|
      if event.node_changed? or event.node_created?
        data = @zk.get(@path).first
        publish_info_about data
        @queue.push :got_event
      end
    end

    @zk.stat @path, :watch => true
    @zk.create @path, 'Hello Event', :mode => :ephemeral

    while true
    end

    @queue.pop
  ensure
    @zk.close!
  end
end

Producer.new(ARGV[0]).run
