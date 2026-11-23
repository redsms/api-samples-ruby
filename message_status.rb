require_relative 'redsms'

def message_status(uuid)
  unless uuid.match?(/\A[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\z/i)
    raise 'Укажите UUID: ruby message_status.rb UUID'
  end
  request_api('GET', 'message/' + uuid, { 'fields' => 'uuid,status,errCode' })
end

if $PROGRAM_NAME == __FILE__
  run do
    abort 'Использование: ruby message_status.rb UUID' unless ARGV.length == 1
    message_status(ARGV.first)
  end
end
