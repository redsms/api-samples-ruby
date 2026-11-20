require 'net/http'
require 'digest'
require 'securerandom'
require 'json'

def required(name)
  value = ENV[name]
  abort "Задайте #{name}" if value.nil? || value.empty?
  value
end

url = URI('https://cp.redsms.ru/api/')
fields = {}
case ARGV
when []
  url.path += 'client/info'
  request = Net::HTTP::Get.new(url)
when ['send']
  url.path += 'message'
  fields = { 'from' => required('REDSMS_FROM'), 'route' => 'sms',
             'text' => 'Тестовое сообщение от redsms.ru', 'to' => required('REDSMS_TO') }
  request = Net::HTTP::Post.new(url)
  request.set_form_data(fields)
else
  uuid = ARGV[1]
  unless ARGV.size == 2 && ARGV.first == 'status' && uuid =~ /\A[\da-f]{8}(?:-[\da-f]{4}){3}-[\da-f]{12}\z/i
    abort 'Использование: ruby client_info.rb [send | status UUID]'
  end
  url.path += "message/#{uuid}"
  fields['fields'] = 'uuid,status,errCode'
  url.query = URI.encode_www_form(fields)
  request = Net::HTTP::Get.new(url)
end

ts = SecureRandom.uuid
values = fields.sort.map(&:last).join
request['login'] = required('REDSMS_LOGIN')
request['ts'] = ts
request['sig'] = Digest::MD5.hexdigest(values + ts + required('REDSMS_API_KEY'))
Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https', open_timeout: 5, read_timeout: 10) do |http|
  response = http.request(request)
  abort "HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
  data = JSON.parse(response.body)
  puts JSON.pretty_generate(data)
  exit 1 unless data['success'] && Array(data['errors']).empty?
end
