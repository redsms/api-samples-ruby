require 'net/http'
require 'digest'
require 'securerandom'
require 'json'

def required(name)
  value = ENV[name]
  raise "Задайте #{name}" if value.nil? || value.empty?
  value
end

def request_api(method, path, fields = {})
  url = URI('https://cp.redsms.ru/api/' + path)
  if method == 'POST'
    request = Net::HTTP::Post.new(url)
    request.set_form_data(fields)
  else
    url.query = URI.encode_www_form(fields) unless fields.empty?
    request = Net::HTTP::Get.new(url)
  end

  ts = SecureRandom.uuid
  values = fields.sort.map(&:last).join
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
end

def run
  yield
rescue StandardError => error
  abort error.message
end
