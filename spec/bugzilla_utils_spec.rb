# frozen_string_literal: true

require 'spec_helper'

describe Bugzilla::Utils do
  before do
    class Foo
      include Bugzilla::Utils
    end
    @info = { URL: 'https://foo.example.org:443/', Proxy: 'http://bar.example.org:8080' }
  end
  describe 'get_xmlrpc' do
    it 'should return an array' do
      expect(Foo.new.get_xmlrpc(@info)).to be_an Array
    end
  end
  describe 'get_proxy' do
    it 'should return an array' do
      expect(Foo.new.get_proxy(@info)).to be_an Array
    end
  end
  describe 'save_config' do
    before do
      @f = Foo.new
      @conf = { bsc: { Name: 'SUSE Bugzilla', URL: 'https://bugzilla.suse.com',
                       Plugin: 'plugins/nvbugzilla.rb' } }
      @opts = { config: 'foo.yaml' }
    end
    after do
      FileUtils.rm 'foo.yaml'
    end
    it 'should save file in the right location' do
      expect { @f.save_config(@opts, @conf) }.not_to raise_error
      expect { File.open(@opts[:config]) }.to_not raise_error
    end
  end

  describe 'read_config' do
    before do
      @f = Foo.new
      @conf = { bsc: { Name: 'SUSE Bugzilla', URL: 'https://bugzilla.suse.com',
                       Plugin: 'plugins/nvbugzilla.rb' } }
      @opts = { config: 'foo.yaml' }
      @f.save_config(@opts, @conf)
    end
    after do
      FileUtils.rm 'foo.yaml'
    end
    it 'should return a conf' do
      expect(@f.read_config(@opts)).to be_an Hash
    end
  end
end
