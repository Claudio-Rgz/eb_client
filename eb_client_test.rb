require 'minitest/autorun'
require 'net/http'
require 'uri'
require_relative 'eb_client'

class EasyBrokerClientTest < Minitest::Test
  def setup
    @api_key = 'test_api_key'
    @client = EasyBrokerClient.new(@api_key)
  end

  def test_list_properties_success
    url = URI("#{@client.instance_variable_get(:@api_root_url)}/properties?page=1&limit=20")
    response_body = {
      'content' => [
        {
          'public_id' => 'EB-123',
          'title' => 'Test Property',
          'location' => 'Test Location',
          'price' => '123456'
        }
      ]
    }.to_json

    response = Net::HTTPSuccess.new('1.1', '200', 'OK')
    response.instance_variable_set(:@read, true)
    response.instance_variable_set(:@body, response_body)

    Net::HTTP.stub :start, response do
      assert_output(/Public ID: EB-123/) { @client.list_properties }
      assert_output(/Title: Test Property/) { @client.list_properties }
      assert_output(/Location: Test Location/) { @client.list_properties }
    end
  end

  def test_list_properties_error
    response = Net::HTTPUnauthorized.new('1.1', '401', 'Unauthorized')

    Net::HTTP.stub :start, response do
      assert_output(/Error: Unauthorized/) { @client.list_properties }
    end
  end
end