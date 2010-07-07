require 'em-synchrony'
require 'em-synchrony/em-mysqlplus'

require 'active_record/connection_adapters/mysql_adapter'

module ActiveRecord
  module ConnectionAdapters

    class EmMysqlAdapter < MysqlAdapter
      def initialize(connection, logger, host_parameters, connection_parameters, config)
        @hostname = host_parameters[0]
        @port = host_parameters[1]
        @connect_parameters, @config = connection_parameters, config
        super(connection, logger, nil, config)
      end

      def connect
        @connection = EventMachine::MySQL.new({
                                                :host => @hostname,
                                                :port => @port,
                                                :user => @config[:username],
                                                :database => @config[:database],
                                                :password => @config[:password],
                                                :socket   => @config[:socket]
        })

        configure_connection
        @connection
      end

    end
  end

  class Base
    def self.em_mysqlplus_connection(config) # :nodoc:
      config = config.symbolize_keys
      host     = config[:host]
      port     = config[:port]
      username = config[:username].to_s if config[:username]
      password = config[:password].to_s if config[:password]

      if config.has_key?(:database)
        database = config[:database]
      else
        raise ArgumentError, "No database specified. Missing argument: database."
      end

      ConnectionAdapters::EmMysqlAdapter.new(nil, logger, [host, port], [database, username, password], config)
    end
  end
end