require 'net/http'
require 'uri'
require 'json'

class EasyBrokerClient
  def initialize(api_key, api_root_url = 'https://api.stagingeb.com/v1')
    @api_key = api_key
    @api_root_url = api_root_url
  end

  def list_properties(page = 1, limit = 20)
    url = URI("#{@api_root_url}/properties?page=#{page}&limit=#{limit}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['accept'] = 'application/json'
    request['X-Authorization'] = @api_key

    response = http.request(request)
    handle_response(response)
  end

  private

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      properties = JSON.parse(response.body)
      properties['content'].each do |property|
        puts "ID: #{property['public_id']}"
        puts "Title: #{property['title']}"
        puts "Location: #{property['location']}"
        puts "-----------------------------------------------"
      end
    else
      puts "Error: #{response.message}"
    end
  end
end

# Use case
api_key = 'l7u502p8v46ba3ppgvj5y2aad50lb9'
client = EasyBrokerClient.new(api_key)
client.list_properties(2, 10)