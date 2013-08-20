require 'colorize'
require 'parseconfig'
require 'thread'
require 'zookeeper'

config  = ParseConfig.new(File.join(File.dirname(__FILE__), "..", "config/settings"))
ZK_IP   = config['global']['zk_ip']
ZK_PORT = config['global']['zk_port']
ZK_PATH = config['global']['zk_path']

class ServiceMonitor
  def initialize()
    print "Service Monitor Initializing...    "

    @existing_services = []
    @services          = []
    @stat              = Zookeeper::Stat.new []
    @zk                = Zookeeper::Client.new "#{ZK_IP}:#{ZK_PORT}"
    @watcher           = method(:watcher)

    # ensure that the /services root node is able to be owned by the monitor
    begin
      @zk.delete ZK_PATH
    rescue
    end

    @zk.create :path => ZK_PATH

    # start the monitoring of services
    @stat = @zk.get_children(:path => ZK_PATH, :watcher => @watcher)[:stat]

    print "[ OK ]\n\n".light_green
  end

  def watcher(*args)
    res              = @zk.get_children :path => ZK_PATH, :watcher => @watcher
    @services, @stat = res[:children], res[:stat]

    if @existing_services.size > @services.size # lost a registered service
      puts "Service(s) with ID #{(@existing_services - @services).join(',').light_red} unregistered\n\n"
    else                                        # gained a registered service
      puts "Service(s) with ID #{(@services - @existing_services).join(',').light_green} registered\n\n"
    end

    puts "SERVICES IDS ONLINE: #{@services.empty? ? 'None'.light_yellow : @services.join(',').light_yellow}\n\n"

    @existing_services = @services
  end

  def run
    @zk.stat(:path => ZK_PATH, :watcher => @watcher) unless @stat.exists

    while true
    end
  ensure
    @zk.close!
  end
end

ServiceMonitor.new.run
