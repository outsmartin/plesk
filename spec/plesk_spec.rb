require "spec_helper"
require "yaml"
include Plesk
describe "Plesk" do
  let(:api) {
    config = YAML.load( File.open "spec/config.yml")
    path = config["path"]
    user = config["user"]
    pass = config["password"]
    Client.new(path,user,pass)
  }

  it "should connect to the Plesk RPC" do
    api.start_request("bla")
    api.response.code.should == "200"
  end

  it "should be able to get basic domain list" do
    api.get_domain_info
    api.response.code.should == "200"
  end
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
    Nokogiri::XML(answer.response.body).at('status').text.should == "ok"
  end
end

describe PleskPacket do
  it "should generate xml" do
    p = PleskPacket.new
    Nokogiri::XML(p.to_xml).errors.should be_empty
  end
  it "should have a packet version matching the param" do
    ver = "1.0.0.0"
    p = PleskPacket.new(ver)
    Nokogiri::XML(p.to_xml).at('packet').attr('version').should == ver
  end
  it "should create a packet to get a domain list" do
    p = PleskPacket.new("1.4.1.2")
    p.domain_info
    Nokogiri::XML(p.to_xml).at('get').children.count.should > 0
  end
  it "should create a packet to get the mailgroup of a mail adress" do
    p = PleskPacket.new("1.6.0.2")
    p.mailgroup_info "developer","1"
    Nokogiri::XML(p.to_xml).at('get_info').children.count.should > 0
  end
end
