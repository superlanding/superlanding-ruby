module SuperLanding
  module API
    class Base

      attr_accessor :base_url, :merchant_no, :access_key

      def initialize(merchant_no, access_key, base_url=nil)
        @merchant_no = merchant_no
        @access_key = access_key
        @base_url = base_url.nil? ? SuperLanding::BASE_URL : base_url
      end

      protected

      def post(path)
        RestClient.post(uri(path).to_s, post_data)
      rescue RestClient::ExceptionWithResponse => e
        e.response
      end

      def get(path)
        RestClient.get(uri(path).to_s)
      rescue RestClient::ExceptionWithResponse => e
        e.response
      end

      # [GET] query string params
      def params
        {}
      end

      # [POST]
      def post_data
        {}
      end

      private

      def uri(path)
        uri = URI.parse("#{base_url}#{path}").tap { |u| u.query = query_auth_params }
      end

      def query_auth_params
        URI.encode_www_form(auth_params.merge(params))
      end

      def auth_params
        { merchant_no: merchant_no, access_key: access_key }
      end
    end
  end
end
