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
    server_ans =  Server.post("http://#{host}/report_activity_users.xml", :body => {
                                :report_activity_user => {
                                  :user_id => id, :activity_id => activity
                                }})
    puts server_ans.parsed_response
    users[id][activity][:id] = server_ans.parsed_response['report_activity_user']['id']
  else  
    repetitions = sp.gets('*').gsub('*', '').to_i    
    users[id][activity][:reps] = repetitions
    puts "Repetitions #{repetitions}"
    thisID = users[id][activity][:id]
    time = repetitions.to_f / (Time.now - users[id][activity][:start]) * 60
    puts "Time #{time}"
    server_ans = Server.put("http://#{host}/report_activity_users/#{thisID}.xml", :body => {
                              :report_activity_user => {
                                :real_time => time
                               }})
    puts server_ans.parsed_response
  end
  #printf("%c\n", sp.getc)
end

sp.close
