require 'spec_helper'

describe Bugzilla::Bugzilla do
  describe :new do
    it 'should not be nil' do
      x = Bugzilla::XMLRPC.new 'bugzilla.suse.com'
      b = Bugzilla::Bugzilla.new x
      expect(b).not_to be_nil
    end
  end
  describe :requires_version do
    before do
      x = Bugzilla::XMLRPC.new 'bugzilla.suse.com'
      @b = Bugzilla::Bugzilla.new x
    end
    context 'version required supported' do
      before do
        stub_request(:post, 'https://bugzilla.suse.com/xmlrpc.cgi')
          .with(
            body: "<?xml version=\"1.0\" ?><methodCall><methodName>Bugzilla.version</methodName><params><param><value><struct/></value></param></params></methodCall>\n",
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'identity',
              'Connection' => 'keep-alive',
              'Content-Length' => '145',
              'Content-Type' => 'text/xml; charset=utf-8',
              'User-Agent' => 'XMLRPC::Client (Ruby 2.4.0)'
            }
          )
          .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><methodResponse><params><param><value><struct><member><name>version</name><value><string>4.3.0</string></value></member></struct></value></param></params></methodResponse>', headers: {})
      end
      it 'should raise exception' do
        expect { @b.requires_version('foo', 6.6) }.to raise_error
      end
      it 'should not raise exception' do
        expect { @b.requires_version('foo', 4.2) }.not_to raise_error
      end
    end
  end
  describe :check_version do
    before do
      x = Bugzilla::XMLRPC.new 'bugzilla.suse.com'
      @b = Bugzilla::Bugzilla.new x
    end
    context 'version 4.3.0' do
      before do
        stub_request(:post, 'https://bugzilla.suse.com/xmlrpc.cgi')
          .with(
            body: "<?xml version=\"1.0\" ?><methodCall><methodName>Bugzilla.version</methodName><params><param><value><struct/></value></param></params></methodCall>\n",
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'identity',
              'Connection' => 'keep-alive',
              'Content-Length' => '145',
              'Content-Type' => 'text/xml; charset=utf-8',
              'User-Agent' => 'XMLRPC::Client (Ruby 2.4.0)'
            }
          )
          .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><methodResponse><params><param><value><struct><member><name>version</name><value><string>4.3.0</string></value></member></struct></value></param></params></methodResponse>', headers: {})
      end
      it 'should return true and the current_version' do
        ret = @b.check_version('4.4.0')
        expect(ret[0]).to be false
        expect(ret[1]).to eq('4.3.0')
      end
    end

    context 'version 4.4.12' do
      before do
        stub_request(:post, 'https://bugzilla.suse.com/xmlrpc.cgi')
          .with(
            body: "<?xml version=\"1.0\" ?><methodCall><methodName>Bugzilla.version</methodName><params><param><value><struct/></value></param></params></methodCall>\n",
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'identity',
              'Connection' => 'keep-alive',
              'Content-Length' => '145',
              'Content-Type' => 'text/xml; charset=utf-8',
              'User-Agent' => 'XMLRPC::Client (Ruby 2.4.0)'
            }
          )
          .to_return(status: 200, body: '<?xml version="1.0" encoding="UTF-8"?><methodResponse><params><param><value><struct><member><name>version</name><value><string>4.4.12</string></value></member></struct></value></param></params></methodResponse>', headers: {})
      end
      it 'should return true and the current_version' do
        ret = @b.check_version('4.4.0')
        expect(ret[0]).to be true
        expect(ret[1]).to eq('4.4.12')
      end
    end
  end
end
