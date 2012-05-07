require "net/https"
require "nokogiri"
module Plesk
  class Client
    attr_accessor :response, :uri,:http
    def initialize path, user, password
      @response = 0
      @uri = URI(path)
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @headers = {
        'HTTP_AUTH_LOGIN' => user,
        'HTTP_AUTH_PASSWD' => password,
        'Accept' => '*/*',
        'Content-Type' => 'text/xml',
      }
      @http = http
    end
    def get_domain_info
      packet = PleskPacket.new
      packet.domain_info
      start_request packet.to_xml
    end
    def get_domain_id_for domain
      packet = PleskPacket.new
      packet.domain_info_for_domain domain
      answer = start_request packet.to_xml
      Nokogiri::XML(answer.body).at('id').text
    end
    def get_mailgroup_info_for mail
      name,domain = mail.split("@")
      domain_id = get_domain_id_for domain
      packet = PleskPacket.new
      packet.mailgroup_info name,domain_id
      answer = start_request packet.to_xml

      Nokogiri::XML(answer.body).search('address').map(&:text)
    end

    def set_mailgroup_for mail,mails
      name,domain = mail.split("@")
      domain_id = get_domain_id_for domain
      packet = PleskPacket.new
      packet.mailgroup_set name,domain_id,mails
      answer = start_request packet.to_xml
    end

    def start_request(body)
      response = http.request_post(@uri.path,body,@headers)
      @response = response
    end
  end
  class PleskPacket
    attr_accessor :content
    def initialize version="1.4.1.2"
      @content = Nokogiri::XML::Builder.new do |xml|
        xml.packet(version: version)
      end.doc
    end
    def domain_info
      doc = @content
      Nokogiri::XML::Builder.with(doc.at('packet')) do |xml|
        xml.domain {
          xml.get {
            xml.filter
            xml.dataset {
              xml.limits
              xml.prefs
            }
          }
        }
      end
    end
    def domain_info_for_domain domain
      doc = @content
      @content=Nokogiri::XML::Builder.with(doc.at('packet')) do |xml|
        xml.domain {
          xml.get {
            xml.filter {
              xml.domain_name domain
            }
            xml.dataset {
              xml.limits
              xml.prefs
            }
          }
        }
      end
    end
    def mailgroup_info name,id
      doc = @content
      @content =Nokogiri::XML::Builder.with(doc.at('packet')) do |xml|
        xml.mail {
          xml.get_info {
            xml.filter {
              xml.name name
              xml.domain_id id
            }
            xml.group
          }
        }
      end
    end
    def mailgroup_set name,id,mails
      doc = @content
      @content =Nokogiri::XML::Builder.with(doc.at('packet')) do |xml|
        xml.mail {
          xml.update {
            xml.set {
              xml.filter {
                xml.domain_id id
                xml.mailname {
                  xml.name name
                  xml.mailgroup {
                    xml.enabled :true
                    mails.each do |mail|
                      xml.address mail
                    end
                  }
                }
              }
            }
          }
        }
      end
    end
    def to_xml
      @content.to_xml
    end
  end
end
