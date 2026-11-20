require 'net/http'
require 'digest'
require 'securerandom'
require 'json'

url = URI('https://cp.redsms.ru/api/client/info')
ts = SecureRandom.uuid
request = Net::HTTP::Get.new(url)
request['login'] = ENV.fetch('REDSMS_LOGIN')
request['ts'] = ts
request['sig'] = Digest::MD5.hexdigest(ts + ENV.fetch('REDSMS_API_KEY'))

Net::HTTP.start(url.host, url.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
  response = http.request(request)
  abort "HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
  puts JSON.pretty_generate(JSON.parse(response.body))
end
