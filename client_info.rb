require_relative 'redsms'

run do
  case ARGV
  when []
    request_api('GET', 'client/info')
  when ['send']
    require_relative 'send_sms'
    send_sms
  else
    abort 'Использование: ruby client_info.rb' unless ARGV.length == 2 && ARGV.first == 'status'
    require_relative 'message_status'
    message_status(ARGV[1])
  end
end
