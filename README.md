# S3Proxy

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 's3proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install s3proxy

# Usage

    # config/s3.yml
    development:
      access_key_id: 'XXXXXXXXXXXXXXXXXXXX'
      secret_access_key: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
      bucket: "myapp-dev"
      region: "ap-northeast-1"

    # config/environments/*.rb
    Rails.application.config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
    S3Proxy.load_file("#{Rails.root}/config/s3.yml")

    # app/uploaders/*.rb
    mattr_accessor :root_dir
    if S3Proxy.loaded?
      use_s3_proxy
      self.root_dir = "uploads"
    else
      storage :file
      self.root_dir = "#{::Rails.root}/uploads"
    end

    # in controller
    send_upload @model.file, type: "image/png", attachment: "inline"

# nginx.conf

    # See S3Proxy.internal_url_prefix
    location ~ ^/protected/s3/(.*)$ {
      resolver 8.8.8.8; # using Google Public DNS
      internal;
      proxy_set_header Authorization ""; # Authorization ヘッダが S3 に渡ると S3 の認証と見なされるため削除
      proxy_set_header Content-Type ""; # Content-Type ヘッダが S3 に渡ると署名が一致しなくなるので削除
      proxy_pass $1?$args;
    }


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
