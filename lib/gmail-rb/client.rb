module Gmail

  class Client

    attr_accessor :options

    def initialize(options = {})
      @options = options
    end

    def connection
      @connection ||= Gmail::Connection.new('https://www.googleapis.com', @options)
    end

  end
end