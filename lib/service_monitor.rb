require 'colorize'
require 'parseconfig'
require 'thread'
require 'zookeeper'

config     = ParseConfig.new(File.join(File.dirname(__FILE__), "..", "config/settings"))
ZK_IP      = config['global']['zk_ip']
ZK_PORT    = config['global']['zk_port']
ZK_PATH    = config['global']['service_subscription_path']
ZK_SERVICE = config['global']['service_analytics_path']

class ServiceMonitor
  ##
  # Initialize the ServiceMonitor instance
  #
  # General initialization of parameters and connection to the ZooKeeper
  # instance where the services are registering/un-registering.
  #
  def initialize()
    print "Service Monitor Initializing...    "

    @existing_services = []
    @services          = []
    @stat              = Zookeeper::Stat.new []
    @zk                = Zookeeper::Client.new "#{ZK_IP}:#{ZK_PORT}"
    @watcher           = method(:watcher)

    # ensure that the /services and /service root nodes are able to be owned by the monitor
    begin
      @zk.delete ZK_PATH
    rescue
    end
    @zk.create :path => ZK_PATH

    begin
      @zk.delete ZK_SERVICE
    rescue
    end
    @zk.create :path => ZK_SERVICE

    # start the monitoring of services
    @stat = @zk.get_children(:path => ZK_PATH, :watcher => @watcher)[:stat]

    print "[ OK ]\n\n".light_green
  end

  ##
  # Keep track of service state
  #
  # Watches the ephemeral nodes corresponding to the services in order to keep
  # track of services registering/un-registering.
  #
  def watcher(*opts)
    res              = @zk.get_children :path => ZK_PATH, :watcher => @watcher
    @services, @stat = res[:children], res[:stat]

    if @existing_services.size > @services.size # lost a registered service
      puts "Service(s) with IP #{(@existing_services - @services).join(', ').light_red} Un-Registered\n\n"
    else                                        # gained a registered service
      puts "Service(s) with IP #{(@services - @existing_services).join(', ').light_green} Registered\n\n"
    end

    puts "Service IPs Online: #{@services.empty? ? 'None'.light_yellow : @services.join(', ').light_yellow}\n\n"

    @existing_services = @services
  end

  ##
  # Obtains information about each registered service
  #
  # Parses the child nodes of the registered services in order to discover and
  # print out the state of the subscribed service.
  #
  def get_services_state
    puts "============================================================================" unless @services.empty?

    @services.each do |service_ip|
      begin
        print "SERVICE (" + "#{service_ip}".yellow + ") "
        @zk.get_children(:path => "#{ZK_SERVICE}/#{service_ip}")[:children].each do |child_node|
          print "| #{child_node.gsub('_', ' ').capitalize} (" + @zk.get(:path => "#{ZK_SERVICE}/#{service_ip}/#{child_node}")[:data].to_s.green + ") "
        end
        print "\n"
      rescue
      end
    end

    puts "============================================================================\n\n" unless @services.empty?
  end

  ##
  # Main method for the ServiceManager class
  #
  def run
    @zk.stat(:path => ZK_PATH, :watcher => @watcher) unless @stat.exists

    # obtain state information about each registered service every second
    while true
      get_services_state
      sleep 1
    end
  ensure
    @zk.close!
  end
end

# run an instance of the ServiceMonitor class
ServiceMonitor.new.run
