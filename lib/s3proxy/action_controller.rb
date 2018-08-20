module S3Proxy
  module ActionController
    module InstanceMethods
      # upload のファイルへの応答を定義する
      # params[:t] があれば 30 日間キャッシュさせる
      # respond_to do |format|
      #   respond_for_upload format, @upload.file, :main, "image/png"
      # end
      def respond_for_upload(format, uploader, version, content_type)
        send_file_proc = lambda {
          # 60 * 60 * 24 * 30 => 2592000
          headers["Cache-Control"] = "max-age=2592000" if params[:t].presence # t があれば30日間キャッシュ
          send_upload(uploader, version, content_type)
        }

        case content_type
        when *%w(image/jpeg image/pjpeg) #--pjpeg
          # JPEGはjpegとjpgの両方の拡張子に応答
          format.jpeg &send_file_proc
          format.jpg &send_file_proc
        when *%w(image/png image/x-png)
          format.png &send_file_proc
        when "image/gif"
          format.gif &send_file_proc
        end
      end

      # upload のファイルを返す
      # x_sendfile_header が指定されていればそれに応じたレスポンスを返す
      def send_upload(uploader, *version_and_options)
        options = version_and_options.extract_options!
        version = version_and_options.first
        uploader = uploader.versions[version.to_sym] if version && uploader.versions.has_key?(version.to_sym)
        options[:filename] ||= File.basename(uploader.path)

        if uploader.use_s3_proxy?
          url = uploader.url
          url = url.gsub(/\Ahttps:/, "http:") unless request.ssl? # url は https で、そのままだと nginx が処理できないため http にする
          # % encoding の処理が複雑になるので リダイレクト先の URL は別ヘッダ (X-Accel-Redirect-To) に
          headers[Rails.application.config.action_dispatch.x_sendfile_header] = S3Proxy.internal_url_prefix
          headers["X-Accel-Redirect-To"] = url
          send_data "", options
        else
          path = uploader.current_path
          send_file path, options
        end
      end
    end

    def self.included(base)
      base.class_eval do
        include InstanceMethods
      end
    end
  end
end
