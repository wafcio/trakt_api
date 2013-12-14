require 'httparty'
require 'string_to_sha1'

class TraktApi::Base
  include HTTParty
  base_uri 'http://api.trakt.tv//'

  attr_reader :client, :uri, :options

  def initialize(client)
    @client = client
    @auth = false
  end

  def auth
    @auth = true

    self
  end

  def optional_auth(options)
    auth if options[:auth]

    self
  end

  def store_uri_and_options(uri, options)
    @uri = uri
    @options = options
  end

  def get(uri, options = {})
    store_uri_and_options(uri, options)
    @method = :get

    self
  end

  def post(uri, options = {})
    store_uri_and_options(uri, options)
    @method = :post

    self
  end

  def query_params(options, fields)
    query_params = fields.map { |key| options[key] ? "#{key}=#{options[key]}" : nil }.compact.join('&')
    query_params.empty? ? query_params : "?#{query_params}"
  end

  def response
    self.class.send(@method, uri, request_options(options))
  end

  def request_options(options = {})
    { body: options }.merge(@auth ? auth_hash : {})
  end

  def auth_hash
    {
      basic_auth: {
        username: username,
        password: password.to_sha1
      }
    }
  end

  def series_uri(series_id)
    "#{api_key}/series/#{series_id}/"
  end

  def api_key
    client.api_key
  end

  def username
    client.username
  end

  def password
    client.password
  end
end
