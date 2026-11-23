require_relative 'redsms'

def send_sms
  request_api('POST', 'message', {
    'route' => 'sms',
    'from' => required('REDSMS_FROM'),
    'to' => required('REDSMS_TO'),
    'text' => 'Тестовое сообщение от redsms.ru'
  })
end

if $PROGRAM_NAME == __FILE__
  run do
    abort 'Использование: ruby send_sms.rb' unless ARGV.empty?
    send_sms
  end
end
