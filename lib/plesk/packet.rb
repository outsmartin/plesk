
module Plesk
  class Packet
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
    def secret_key_for_ip ip
      doc = @content
      Nokogiri::XML::Builder.with(doc.at('packet')) do |xml|
        xml.secret_key {
          xml.create {
          xml.ip_address ip
        }
        }
      end
    end
    def to_xml
      @content.to_xml
    end
  end
end
