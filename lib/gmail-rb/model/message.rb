module Gmail
  module Model

    class Message
      require 'base64'

      attr_accessor :id, :thread_id, :labels, :subject, :to, :from, :cc, :bcc, :date, :message_html, :message_text, :attachments, :raw, :snippet

      def initialize(opts)
        @id = opts.fetch('id')
        @thread_id = opts.fetch('threadId')
        @labels = opts.try('labelIds')
        @snippet = opts.try('snippet')

        # Process headers
        opts['payload']['headers'].each do |h|
          next if h['name'].blank?
          case h['name']
            when 'From';    @from = parse_recipients(h['value']).first
            when 'To';      @to = parse_recipients(h['value'])
            when 'Cc';      @cc = parse_recipients(h['value'])
            when 'Bcc';     @bcc = parse_recipients(h['value'])
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


    protected

      # Decode the message body with URL-safe Base64.
      def decode_body(body)
        body += '=' * (4 - body.length.modulo(4))
        Base64.decode64(body.tr('-_','+/'))
      end

      # Convert recipients to array list
      def parse_recipients(addresses)
        list_addresses = addresses.gsub(/[\r\n]+/, '').gsub(/(@((?:[-a-z0-9]+\.)+[a-z]{2,})(\>)?)\,/i, '\1'+"\n")
        list_addresses.split("\n").map{|full_address|
          {'name' => extract_name(full_address), 'email' => extract_email_address(full_address)}
        }
      end

      # Sampled from griddler gem
      def extract_name(full_address)
        full_address = full_address.strip
        name = full_address.split('<').first.strip
        if name.present? && name != full_address
          name
        end
      end

      def extract_email_address(full_address)
        full_address.split('<').last.delete('>').strip
      end

    end
  end
end