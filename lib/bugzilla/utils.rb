module Bugzilla
  module Utils
    def get_proxy(info)
      uri = info[:Proxy] || ENV['http_proxy']
      proxy_uri = uri.nil? ? nil : URI.parse(uri)
      proxy_host = proxy_uri.nil? ? nil : proxy_uri.host
      proxy_port = proxy_uri.nil? ? nil : proxy_uri.port
      [proxy_host, proxy_port]
    end

    def get_xmlrpc(conf = {}, opts = {})
      info = conf
      uri = URI.parse(info[:URL])
      host = uri.host
      port = uri.port
      path = uri.path.empty? ? nil : uri.path
      proxy_host, proxy_port = get_proxy(info)
      timeout = opts[:timeout].nil? ? 60 : opts[:timeout]
      yield host if block_given? # if you want to run some pre hook
      xmlrpc = XMLRPC.new(host, port: port, path: path, proxy_host:
                                    proxy_host, proxy_port: proxy_port, timeout:
                                    timeout, http_basic_auth_user: uri.user,
                                http_basic_auth_pass: uri.password, debug: opts[:debug])
      [xmlrpc, host]
    end
    def read_config(opts)
      fname = opts[:config].nil? ? @defaultyamlfile : opts[:config]
      begin
        # TODO: fix config file
        # Psych doesnt allow Symbol as class
        # conf = YAML.safe_load(File.open(fname).read)
        conf = YAML.load(File.open(fname).read)
      rescue Errno::ENOENT
        conf = {}
      end
      conf.each do |_k, v|
        load(File.join(File.dirname(__FILE__),v[:Plugin])) if v.is_a?(Hash) && v.include?(:Plugin)
      end
      conf
    end # def read_config

    def save_config(opts, conf)
      fname = opts[:config].nil? ? @defaultyamlfile : opts[:config]
      if File.exist?(fname)
        st = File.lstat(fname)
        if st.mode & 0o600 != 0o600
          raise format('The permissions of %s has to be 0600', fname)
        end
      end
      File.open(fname, 'w') { |f| f.chmod(0o600); f.write(conf.to_yaml) }
    end # def save_config
  end
end
