require 'socket'
require 'time'

# Method to display the list of commands
def show_commands
  puts "\033[36m"  # Light cyan colour
  puts "\n=========* Commands *============="
  puts "= Type 'exit' to leave the chatroom ="
  puts "= /users to list all users         ="
  puts "= /nick new_name to change nickname ="
  puts "= /help to list all commands        ="
  puts "===================================\033[0m"  # Reset to default colour
end

puts "Enter the server's IP address: "
server_ip = gets.chomp
client = TCPSocket.new(server_ip, 12345)

puts "Connected to the chatroom. Type 'exit' to leave."
show_commands

Thread.new do
  loop do
    begin
      message = client.gets.chomp
      puts message # Display incoming messages as they are formatted by the server
    rescue StandardError
      puts "Disconnected from the server."
      client.close
      exit
    end
  end
end

loop do
  input = gets.chomp
  client.puts input
  
  break if input.downcase == 'exit'
end

client.close
