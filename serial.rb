require 'serialport'
require 'httparty'

class Server
  include HTTParty
end

host = ARGV.shift

port = "/dev/ttyUSB0"
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

sp = SerialPort.new(port, baud_rate, data_bits, stop_bits, parity)

users = {}

loop do
  #puts sp.gets('*')
  puts "Receiving..."
  id = sp.gets('*').gsub('*', '').to_i
  users[id] ||= {}
  activity = sp.gets('*').gsub('*', '').to_i
  if users[id][activity].nil? # register activity
    users[id][activity] = {:start => Time.now}
    server_ans =  Server.post("#{host}/report_activity_users.xml", :body => {
                                :report_activity_user => {:user_id => id, :activity_id => activity
                                }})
    puts server_ans.parsed_response
    puts users[id][activity][:id] = server_ans.parsed_response['report_activity_user']['id']
  #else
  end
    repetitions = sp.gets('*')    
    users[id][activity][:reps] = repetitions
  puts "Repetitions #{repetitions}"
    thisID = users[id][activity][:id]
    server_ans = Server.put("#{host}/report_activity_users/#{thisID}.xml", :body => {:report_activity_user => {
                  :user_id => id, :activity_id => activity, :real_time => (repetitions.to_f / (Time.now - users[id][activity][:start]))
                               }})
    puts server_ans.parsed_response
  #end
  #printf("%c\n", sp.getc)
end

sp.close
