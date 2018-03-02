require 'spec_helper'

describe Bugzilla::XMLRPC do
  describe :new do
    context 'just hostname as parameter' do
      before do
        @xmlrpc = Bugzilla::XMLRPC.new('bugzilla.suse.com')
      end
      it 'should not be nil just with host' do
        expect(@xmlrpc).not_to be_nil
      end
      it 'should default have ssl enabled' do
        expect(@xmlrpc.use_ssl?).to be true
      end
    end
  end
end
