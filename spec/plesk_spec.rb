require "spec_helper"
require "yaml"
require "ostruct"
include Plesk
describe "Plesk" do
  let(:api) {
    config = YAML.load( File.open "spec/config.yml")
    host = config["host"]
    user = config["user"]
    pass = config["password"]
    Client.new(host,user,pass)
  }
  let(:api_via_key) {
    config = YAML.load( File.open "spec/config.yml")
    host = config["host"]
    key = config["key"]
    Client.new(host,key)
  }

  it "should connect to the Plesk RPC" do
    api.start_request("bla")
    api.response.code.should == "200"
  end
  it "should connect to the Plesk RPC via secret key" do
    api_via_key.start_request("bla")
    api_via_key.response.code.should == "200"
  end

  #it "should be able to get basic domain list" do
  #api.get_domain_info
  #api.response.code.should == "200"
  #end
  it "should be able to find domain id by name" do
    id = api.get_domain_id_for "itsax.de"
    id.should be_kind_of String
  end
  it "should get a mailgroup list for a mail" do
    mails = api.get_mailgroup_info_for "developer@pludoni.de"
    mails.should be_kind_of Array
  end
  it "should set mailgroup for a mail" do
    mails_to_set = ["stefan.wienert@pludoni.de","akos.toth@pludoni.de","martin.schneider@pludoni.de"]
    answer = api.set_mailgroup_for "developer@pludoni.de", mails_to_set
    answer.at('status').text.should == "ok"
  end
  it "should be able to retrieve the api secret" do
    #ip = "46.4.99.113"
    #answer = api.get_secret_for_ip ip
    #Nokogiri::XML(answer.response.body).at('status').text.should == "ok"
    #Nokogiri::XML(answer.response.body).at('key').text.to_s.length.should > 10
  end
  it "should have a convenient way to get the key" do
    ip = "46.4.99.113"
    answer = api.get_secret_for_ip ip
    answer.should be_kind_of String
    (10..50).should include answer.length
  end

  it "should raise an error when plesk" do
    object = OpenStruct.new body: "ERROR", code: "500"

    Net::HTTP.any_instance.should_receive(:request_post).and_return(object)
    ip = "46.4.99.113"

    lambda {
    answer = api.get_secret_for_ip ip
    }.should raise_error(PleskException)
  end
end

describe Packet do
  it "should generate xml" do
    p = Packet.new
    Nokogiri::XML(p.to_xml).errors.should be_empty
  end
  it "should have a packet version matching the param" do
    ver = "1.0.0.0"
    p = Packet.new(ver)
    Nokogiri::XML(p.to_xml).at('packet').attr('version').should == ver
  end
  it "should create a packet to get a domain list" do
    p = Packet.new("1.4.1.2")
    p.domain_info
    Nokogiri::XML(p.to_xml).at('get').children.count.should > 0
  end
  it "should create a packet to get the mailgroup of a mail adress" do
    p = Packet.new("1.6.0.2")
    p.mailgroup_info "developer","1"
    Nokogiri::XML(p.to_xml).at('get_info').children.count.should > 0
  end
  it "should create a packet to retrieve the secret" do
    ip = "192.0.0.1"
    p = Packet.new
    p.secret_key_for_ip ip
    Nokogiri::XML(p.to_xml).at('ip_address').text.should == ip
  end
end
