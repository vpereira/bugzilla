# frozen_string_literal: true

require 'spec_helper'

describe Bugzilla::User do
  before do
    x = Bugzilla::XMLRPC.new 'bugzilla.suse.com'
    @u = Bugzilla::User.new x
  end
  describe :new do
    it 'should not be nil' do
      expect(@u).not_to be_nil
    end
  end
  describe 'protected methods' do
    describe :is_token_supported? do
      let(:http_request) do
        <<~XML
          <?xml version=\"1.0\" ?>\
          <methodCall><methodName>Bugzilla.version</methodName>\
          <params><param><value><struct/></value></param></params>\
          </methodCall>
        XML
      end
      let(:http_response) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>\
          <methodResponse><params>\
          <param><value><struct><member><name>version</name>\
          <value><string>4.5.0</string></value></member></struct></value></param></params>\
          </methodResponse>
        XML
      end
      before do
        stub_request(:post, 'https://bugzilla.suse.com/xmlrpc.cgi')
          .with(
            body: http_request,
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'identity',
              'Connection' => 'keep-alive',
              'Content-Length' => '145',
              'Content-Type' => 'text/xml; charset=utf-8',
              'User-Agent' => 'XMLRPC::Client (Ruby 2.6.5)'
            }
          )
          .to_return(status: 200, body: http_response, headers: {})
      end
      it 'should return true' do
        expect(@u.send(:is_token_supported?)).to be true
      end
    end
    describe :authentication_method do
      context 'working with tokens' do
        before do
          allow(@u).to receive(:is_token_supported?).and_return(true)
        end
        it 'should return token and the filepath for the storage' do
          r = @u.send(:authentication_method)
          expect(r[0]).to be :token
          expect(r[1]).to eq(File.join(ENV['HOME'], '.ruby-bugzilla-token.yml'))
        end
      end
      # context 'working with cookies' do
      # end
    end
  end
end
