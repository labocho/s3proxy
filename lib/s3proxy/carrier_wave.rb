module S3Proxy
  module CarrierWave
    module ClassMethods
      @@use_s3_proxy = false

      def use_s3_proxy
        if Rails.application.config.action_dispatch.x_sendfile_header.blank?
          raise "Cannot use S3Proxy if Rails.application.config.action_dispatch.x_sendfile_header is blank"
        end

        configure do |c|
          c.storage = :fog
          c.fog_credentials = {
            :provider               => 'AWS',       # required
            :aws_access_key_id      => S3Proxy.access_key_id,     # required
            :aws_secret_access_key  => S3Proxy.secret_access_key, # required
            :region                 => S3Proxy.region             # optional, defaults to 'us-east-1'
          }
          # s3 バケット名
          c.fog_directory  = S3Proxy.bucket

          # carrierwave が返す画像の URL のホスト名
          # デフォルトは nil で、S3 のホスト名が返る
          # 内部 URL などを返すのに使う
          #c.fog_host       = "http://s3-ap-northeast-1.amazonaws.com/#{FOG_DIR}" # optional, defaults to nil
          c.fog_public     = false

          #c.fog_authenticated_url_expiration = 600 # 認証つき URL の有効時間(秒)
          #c.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
        end

        # サブクラスとも共有するためクラス変数を使う
        @@use_s3_proxy = true
      end

      def use_s3_proxy?
        @@use_s3_proxy
      end
    end

    module InstanceMethods
      def use_s3_proxy?
        self.class.use_s3_proxy?
      end
    end

    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
  end
end
