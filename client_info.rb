require 'net/http'
require 'digest'
require 'securerandom'
require 'json'

def required(name)
  value = ENV[name]
  raise "Задайте #{name}" if value.nil? || value.empty?
  value
end

begin
  abort 'Использование: ruby client_info.rb' unless ARGV.length == 0
  url = URI('https://cp.redsms.ru/api/client/info')
  values = ''
  request = Net::HTTP::Get.new(url)
  ts = SecureRandom.uuid
  request['login'] = required('REDSMS_LOGIN')
  request['ts'] = ts
  request['sig'] = Digest::MD5.hexdigest(values + ts + required('REDSMS_API_KEY'))
  Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https', open_timeout: 5, read_timeout: 10) do |http|
    response = http.request(request)
    raise "HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    puts JSON.pretty_generate(data)
    exit 1 unless data['success'] && Array(data['errors']).empty?
  end
rescue StandardError => error
  abort error.message
end
