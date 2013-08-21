require 'colorize'
require 'curses'
require 'parseconfig'
require 'thread'
require 'zookeeper'

include Curses

config      = ParseConfig.new(File.join(File.dirname(__FILE__), "..", "config/settings"))
ZK_IP       = config['global']['zk_ip']
ZK_PORT     = config['global']['zk_port']
ZK_PATH     = config['global']['service_subscription_path']
ZK_SERVICE  = config['global']['service_analytics_path']

# screen layout
TOP_HEADER_OFFSET  = 3
LEFT_HEADER_OFFSET = 5
TOP_OFFSET         = 5
LEFT_OFFSET        = 5
COLUMN_WIDTHS      = 15

class TerminalMonitor
  ##
  # Initialize the TerminalMonitor instance
  #
  # General initialization of parameters and connection to the ZooKeeper
  # instance where the services are registering/un-registering.
  #
  def initialize()
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

    # set up the curses (on-screen update) functionality
    noecho              # do not show typed keys
    init_screen         # initialize the screen
    curs_set 0          # hide the cursor
    stdscr.keypad(true) # enable arrow keys

    print "Terminal Monitor Initializing...    " + "[ OK ]\n\n".light_green
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

    # remove un-registered services from view
    if @existing_services.size > @services.size
      (@existing_services - @services).each do |lost_service|
        setpos (@existing_services.index(lost_service) + TOP_OFFSET), LEFT_OFFSET
        deleteln
        refresh
      end
    end

    @existing_services = @services
  end

  ##
  # Obtains information about each registered service
  #
  # Parses the child nodes of the registered services in order to discover and
  # print out the state of the subscribed service.
  #
  def get_services_state
    unless @services.empty?
      # build the services header
      header = "| %-#{COLUMN_WIDTHS}s | " % "IP Address"
      analytical_data = @zk.get_children(:path => "#{ZK_SERVICE}/#{@services[0]}")[:children]
      header += ("%-#{COLUMN_WIDTHS}s | " * analytical_data.size) % analytical_data.map{ |header| header.gsub('_', ' ').capitalize }

      # display the services header
      setpos TOP_HEADER_OFFSET, LEFT_HEADER_OFFSET
      clrtoeol
      refresh
      addstr header
      refresh

      # create outline for headings (columns * column widths + extra spacing for outer bounds)
      table_width = ((COLUMN_WIDTHS * (analytical_data.size + 1)) + 2 + (analytical_data.size * 4))
      setpos (TOP_HEADER_OFFSET - 1), LEFT_HEADER_OFFSET
      clrtoeol
      refresh
      addstr ("=" * table_width)
      setpos (TOP_HEADER_OFFSET + 1), LEFT_HEADER_OFFSET
      clrtoeol
      refresh
      addstr ("=" * table_width)

      # output the status of each service
      @services.each_with_index do |service_ip, i|
        service_status = "| %-#{COLUMN_WIDTHS}s | " % service_ip

        @zk.get_children(:path => "#{ZK_SERVICE}/#{service_ip}")[:children].each do |child_node|
          service_status += "%-#{COLUMN_WIDTHS}s | " % @zk.get(:path => "#{ZK_SERVICE}/#{service_ip}/#{child_node}")[:data].to_s
        end

        setpos (i + TOP_OFFSET), LEFT_OFFSET
        clrtoeol
        refresh
        addstr service_status
        refresh
      end
    end
  end

  ##
  # Main method for the TerminalMonitor class
  #
  def run
    @zk.stat(:path => ZK_PATH, :watcher => @watcher) unless @stat.exists

    while true
      get_services_state
      sleep 1
    end
  ensure
    @zk.close!
    Curses.close_screen
  end
end

# run an instance of the TerminalMonitor class
TerminalMonitor.new.run
