module Sorcery
  module Providers
    # This class adds support for OAuth with discordapp.com

    class Intercom < Base
      include Protocols::Oauth2

      attr_accessor :auth_url, :token_url, :user_info_path, :state

      def initialize
        super

        @auth_url       = 'https://app.intercom.com/oauth'
        @token_url      = 'https://api.intercom.io/auth/eagle/token'
        @user_info_path = 'https://api.intercom.io/me'
        @state          = SecureRandom.hex(16)
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)
        body = JSON.parse(response.body)
        auth_hash(access_token).tap do |h|
          h[:user_info] = body
          h[:uid] = body['id']
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(_params, _session)
        authorize_url(authorize_url: auth_url)
      end

      # tries to login the user from access token
      def process_callback(params, _session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end
        get_access_token(
          args,
          token_url: token_url,
          client_id: @key,
          client_secret: @secret,
          token_method: :post
        )
      end
    end
  end
end
