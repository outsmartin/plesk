require "net/https"
require "nokogiri"
require "open-uri"
module Plesk
  class Client
    attr_accessor :response, :uri,:http
    def initialize host, *credentials
      if credentials.size == 2
        @headers = {
          'HTTP_AUTH_LOGIN' => credentials[0],
          'HTTP_AUTH_PASSWD' => credentials[1],
          'Accept' => '*/*',
          'Content-Type' => 'text/xml',
        }
      elsif credentials.length == 1
        @headers = {
          'KEY' => credentials[0],
          'Accept' => '*/*',
          'Content-Type' => 'text/xml',
        }
      else
        raise ArgumentError
      end
      @response = 0
      @uri = URI.parse "https://example.com:8443/enterprise/control/agent.php"
      @uri.host = host
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @http = http
    end
    def get_domain_id_for domain
      packet = Packet.new
      packet.domain_info_for_domain domain
      answer = start_request packet.to_xml
      answer.at('id').text
    end
    def get_mailgroup_info_for mail
      name,domain = mail.split("@")
      domain_id = get_domain_id_for domain
      packet = Packet.new "1.4.1.2"
      packet.mailgroup_info name,domain_id
      xml = packet.to_xml
      answer = start_request xml
      answer.search('address').map(&:text)
    end
    def set_mailgroup_for mail,mails
      raise "Do not use set, Plesk setting of mailgroups seems to be broken. User reset_mailgroups instead"
      name,domain = mail.split("@")
      domain_id = get_domain_id_for domain
      packet = Packet.new
      packet.mailgroup_set name,domain_id,mails
      answer = start_request packet.to_xml
    end
    def get_secret_for_ip ip
      packet = Packet.new
      packet.secret_key_for_ip ip
      answer = start_request packet.to_xml
      if answer.at('status').text == "ok"
        answer.at('key').text
      else
        $stderr.puts answer.body
        raise PleskException
      end
    end

    def start_request(body)
      response = http.request_post(@uri.path,body,@headers)
      if (400...600).include? response.code.to_i
        raise PleskException
      end
      @response = response
      Nokogiri::XML(response.body)
    end


    def reset_mailgroups(mail_group_name,  new_mails)
      name,domain = mail_group_name.split("@")
      domain_id = get_domain_id_for domain
      old_mails = get_mailgroup_info_for mail_group_name
      p old_mails

      packet = Packet.new
      start_request packet.mailgroup_general("remove", domain_id, name, "false" , old_mails).to_xml
      if new_mails.count > 0
        packet = Packet.new
        start_request packet.mailgroup_general("add", domain_id, name, "true" , new_mails).to_xml
      end
    end
    private

    def get_domain_info
      packet = Packet.new
      packet.domain_info
      start_request packet.to_xml
    end
  end
end
