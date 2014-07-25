module Gmail
  module Model

    class Message
      require 'base64'

      attr_accessor :id, :thread_id, :labels, :subject, :to, :from, :cc, :bcc, :date, :message_html, :message_text, :attachments, :raw, :snippet

      def initialize(opts)
        @id = opts.fetch('id')
        @thread_id = opts.fetch('threadId')
        @labels = opts.fetch('labelIds')
        @snippet = opts.fetch('snippet')

        # Process headers
        opts['payload']['headers'].each do |h|
          next if h['name'].blank?
          case h['name']
            when 'From';    @from = h['value']
            when 'To';      @to = h['value']
            when 'Cc';      @cc = h['value']
            when 'Bcc';     @bcc = h['value']
            when 'Subject'; @subject= h['value']
            when 'Date';    @date= h['value']
          end 
        end

        # Get the standard payload body, if exists
        # (NB: This could be sniffed better based on size of payload parts)
        unless opts['payload']['mimeType'].match(/multipart\/alternative/i)
          body = decode_body(opts['payload']['body']['data'])

          case opts['payload']['mimeType']
            when 'text/html';    @message_html = body
            when 'text/plain';   @message_text = body
          end

        else
          opts['payload']['parts'].each do |p|
            body = decode_body(p['body']['data'])

            case p['mimeType']
              when 'text/html';    @message_html = body
              when 'text/plain';   @message_text = body
            end
          end
        end
      end

      # Decode the message body with URL-safe Base64.
      def decode_body(body)
        str += '=' * (4 - str.length.modulo(4))
        Base64.decode64(str.tr('-_','+/'))
      end

    end
  end
end