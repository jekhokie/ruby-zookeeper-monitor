require 'colorize'
require 'parseconfig'
require 'thread'
require 'zookeeper'

config       = ParseConfig.new(File.join(File.dirname(__FILE__), "..", "config/settings"))
ZK_IP        = config['global']['zk_ip']
ZK_PORT      = config['global']['zk_port']
ZK_PATH      = config['global']['zk_path']
NUM_SERVICES = config['simulator']['num_services']

class Simulator
  def initialize(service_id)
    @service_id = service_id
    @zk         = Zookeeper::Client.new "#{ZK_IP}:#{ZK_PORT}"

    puts "Simulator Thread Initialized for Service ID: #{@service_id}"
  end

  def run
    # generate a presence notification (ephemeral mode)
    @zk.create :path => "#{ZK_PATH}/#{@service_id}", :ephemeral => true

    sleep rand(10)
  ensure
    @zk.close!
  end
end

# run the simulator
threads = []
NUM_SERVICES.to_i.times do |counter|
  threads << Thread.new { Simulator.new(counter).run }
  sleep rand(3)
end

threads.each { |t| t.join }
