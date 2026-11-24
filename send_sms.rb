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
  abort 'Использование: ruby send_sms.rb' unless ARGV.length == 0
  url = URI('https://cp.redsms.ru/api/message')
  recipient = required('REDSMS_TO')
  abort 'Укажите один номер в международном формате, например +12025550123.' unless /\A[+]?[1-9][0-9]{1,14}\z/.match?(recipient)
  fields = { 'from' => required('REDSMS_FROM'), 'route' => 'sms',
             'text' => 'Тестовое сообщение от redsms.ru', 'to' => recipient }
  values = fields.sort.map(&:last).join
  request = Net::HTTP::Post.new(url)
  request.set_form_data(fields)
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
