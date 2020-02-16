# frozen_string_literal: true

require 'spec_helper'

describe Bugzilla::Bug do
  before do
    x = Bugzilla::XMLRPC.new 'bugzilla.suse.com'
    @b = Bugzilla::Bug.new x
  end
  describe :new do
    it 'should not be nil' do
      expect(@b).to_not be_nil
    end
  end
  describe :get_bugs do
    context 'fields default' do
      before do
        allow(@b).to receive(:get).and_return('bugs' => [{ 'id' => '1', 'comments' => 'foo' }])
        allow(@b).to receive(:get_comments).and_return('1' => { 'comments' => 'foo' })
      end
      it 'should return an array and dont raise error' do
        expect { @b.get_bugs([113, 114]) }.to_not raise_error
        expect(@b.get_bugs([113, 114])).to be_an Array
      end
      it 'should raise wrap bugs in an array' do
        expect(@b.get_bugs(1)).to be_an Array
      end
      it 'should raise error' do
        expect { @b.get_bugs(nil).to raise_error }
      end
    end
    context 'fields FIELDS_ALL' do
      before do
        allow(@b).to receive(:get).and_return('bugs' => [{ 'id' => '1', 'comments' => 'foo' }])
        allow(@b).to receive(:get_comments).and_return('1' => { 'comments' => 'foo' })
      end
      it 'should return comments and an array' do
        expect { @b.get_bugs([113, 114], Bugzilla::Bug::FIELDS_ALL) }.to_not raise_error
        expect(@b.get_bugs(1)).to be_an Array
        expect(@b.get_bugs(1)[0]['comments']).to eq('foo')
      end
    end
  end
  describe :get_comments do
    before do
      allow(@b).to receive(:check_version).and_return([false, '3.4.1'])
      allow(@b).to receive(:comments).and_return('bugs' => { '889526' => { 'comments' => [{ 'creator' => 'vpereira@microfocus.com',
                                                                                            'time' => Time.now, 'bug_id' => 889_526,
                                                                                            'author' => 'vpereira@microfocus.com', 'text' => '' }] } })
    end
    it 'should not raise error' do
      expect { @b.get_comments(1) }.to_not raise_error
    end
  end
end
