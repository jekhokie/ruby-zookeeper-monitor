require 'colorize'
require 'parseconfig'
require 'thread'
require 'zookeeper'

config       = ParseConfig.new(File.join(File.dirname(__FILE__), "..", "config/settings"))
ZK_IP        = config['global']['zk_ip']
ZK_PORT      = config['global']['zk_port']
ZK_PATH      = config['global']['service_subscription_path']
ZK_SERVICE   = config['global']['service_analytics_path']
NUM_SERVICES = config['simulator']['num_services'].to_i
MAX_CAPACITY = config['simulator']['max_capacity'].to_i

class Simulator
  ##
  # Initialize the Simulator instance
  #
  # General initialization of parameters and connection to the ZooKeeper
  # instance where the services will register/un-register.
  #
  def initialize(service_id)
    @service_id = service_id
    @zk         = Zookeeper::Client.new "#{ZK_IP}:#{ZK_PORT}"

    puts "Simulator Thread Initialized for Service with IP: #{@service_id}"
  end

  ##
  # Main method for the Simulator class
  #
  def run
    # generate a presence notification (ephemeral mode)
    @zk.create :path => "#{ZK_PATH}/#{@service_id}", :ephemeral => true

    # generate analytical data
    begin
      @zk.delete :path => "#{ZK_SERVICE}/#{@service_id}"

      @zk.create :path => "#{ZK_SERVICE}/#{@service_id}"
      @zk.create :path => "#{ZK_SERVICE}/#{@service_id}/processing"
      @zk.create :path => "#{ZK_SERVICE}/#{@service_id}/capacity_remaining"

      # modify the analytical data randomly
      (1 + rand(10)).times do |counter|
        new_processing = 1 + rand(9999)

        @zk.set :path => "#{ZK_SERVICE}/#{@service_id}/processing",         :data => new_processing.to_s
        @zk.set :path => "#{ZK_SERVICE}/#{@service_id}/capacity_remaining", :data => (MAX_CAPACITY - new_processing).to_s

        sleep rand(5)
      end
    rescue
    end
  ensure
    @zk.close!
  end
end

# run the simulator
threads = []
NUM_SERVICES.times do |counter|
  threads << Thread.new { Simulator.new("10.0.24.#{counter + 2}").run }
  sleep rand(3)
end

threads.each { |t| t.join }
