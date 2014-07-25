module Gmail

  class Threads < Client

    def list(opts = {})

      # Work out what to pass to the call
      conn_body = {}
      conn_body[:maxResults] = opts.fetch(:max_results) { '20' }
      conn_body[:labelIds] = opts.fetch(:labels) unless opts.fetch(:labels) { nil }.nil?
      conn_body[:pageToken] = opts.fetch(:page_token) { nil } unless opts.fetch(:page_token) { nil }.nil?
      conn_body[:q] = opts.fetch(:q) unless opts.fetch(:q).blank?

      # Make the call
      response = connection.get '/gmail/v1/users/me/threads', conn_body

      # Parse the thread list
      JSON.parse(response.body)
    end

    def get(id)
      response = connection.get "/gmail/v1/users/me/threads/#{id}", {prettyPrint: false}
      parsed = JSON.parse(response.body)

      raise Gmail::Error::Unauthorized if parsed.keys.include?('error')

      parsed['messages'].map!{|m| Model::Message.new(m) }
      parsed
    end

  end

end