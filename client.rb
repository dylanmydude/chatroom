require 'socket'

puts "Enter the server's IP address: "
server_ip = gets.chomp
client = TCPSocket.new(server_ip, 12345)

puts "Connected to the chatroom. Type 'exit' to leave."

Thread.new do
  loop do
    begin
      message = client.gets.chomp
      puts message
    rescue StandardError
      puts "Disconnected from the server."
      client.close
      exit
    end
  end
end

loop do
  print "You: "
  input = gets.chomp
  client.puts input
  
  break if input.downcase == 'exit'
end

client.close
