require "s3proxy/version"

module S3Proxy
  CONFIGURATIONS = [:internal_url_prefix, :access_key_id, :secret_access_key, :bucket, :region]

  autoload :ActionController, "s3_proxy/action_controller"
  autoload :CarrierWave, "s3_proxy/carrier_wave"

  mattr_accessor *CONFIGURATIONS

  module_function
  def load_file(path, env = Rails.env)
    load(YAML.load_file(path)[env.to_s])
  end

  def load(config)
    config.each do |k, v|
      raise "Cannot recognize configutation #{k.inspect}" unless CONFIGURATIONS.include?(k.to_sym)
      self.send("#{k}=", v)
    end
    @loaded = true
  end

  def internal_url_prefix
    @internal_url_prefix ||= "/protected/s3/"
  end

  def to_internal_url(url)
    internal_url_prefix + url
  end

  def use_as_default
    ::CarrierWave::Uploader::Base.send :use_s3_proxy
  end

  def loaded?
    @loaded
  end
end

::CarrierWave::Uploader::Base.send(:include, ::S3Proxy::CarrierWave)
::ActionController::Base.send(:include, ::S3Proxy::ActionController)
