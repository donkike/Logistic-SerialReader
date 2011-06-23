require 'logistic/serial_reader'
require 'logistic/server'

class Logistic
  
  attr_reader :users, :host
  
  def initialize(port, host='localhost')
    @users = {}
    @reader = SerialReader.new(port)
    @host = host
  end
  
  def run  
    loop do
      user_id = @reader.read.to_i
      activity_id = @reader.read.to_i
      users[user_id] ||= {}
      if users[user_id][activity_id].nil?
        puts "New activity arrived (user_id: #{user_id}, activity_id: #{activity_id})"
        users[user_id][activity_id] = {:start => Time.now}
        response = Server.post("http://#{host}/report_activity_users.xml",
                                :body => {
                                  :report_activity_user => {
                                    :user_id => user_id, :activity_id => activity_id
                                  }
                                })
        users[user_id][activity_id][:id] = reponse.parsed_response['report_activity_user']['id']
      else
        puts "Activity update: (user_id: #{user_id}, activity_id: #{activity_id})"
        activities_done = @reader.read.to_i
        puts "Update is activities done: #{activities_done}"
        time = Time.now
        users[user_id][activity_id][:done] = activities_done
        average = activities_done / (Time.now - user[user_id][activity_id][:start]) * 60
        response = Server.put("http://#{host}/report_activity_users/#{user[user_id][activity_id][:id]}.xml",
                              :body => {
                                :real_time => average
                              })
      end
    end
    @reader.close    
  end
  
end