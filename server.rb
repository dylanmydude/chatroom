require 'socket'
require 'time'

USER_COLOURS = [
  "\033[31m", # Red
  "\033[32m", # Green
  "\033[33m", # Yellow
  "\033[34m", # Blue
  "\033[35m", # Magenta
  "\033[36m", # Cyan
  "\033[91m", # Light Red
  "\033[92m", # Light Green
  "\033[93m", # Light Yellow
  "\033[94m", # Light Blue
  "\033[95m", # Light Magenta
  "\033[96m"  # Light Cyan
]

RESET_COLOR = "\033[0m"

server = TCPServer.new('0.0.0.0', 12345) # Bind to all network interfaces
clients = []
usernames = {}
user_colours = {}

puts "Chatroom server started. Waiting for clients to connect..."

def broadcast(clients, sender, message, sender_color)
  timestamp = Time.now.strftime("%H:%M:%S")
  formatted_message = "#{sender_color}#{sender} (#{timestamp}): #{message}#{RESET_COLOR}"
  clients.each do |c|
    c.puts formatted_message unless c == sender
  end
end

loop do
  client = server.accept
  clients << client
  user_colours[client] = USER_COLOURS[clients.size % USER_COLOURS.size]
  usernames[client] = client.peeraddr[2]
  puts "New client connected: #{usernames[client]}"

  Thread.new(client) do |conn|
    conn.puts "Welcome to the chatroom! Type /help for a list of commands."

    loop do
      begin
        message = conn.gets.chomp
        puts "Received: #{message} from #{usernames[conn]}"

        case message
        when '/help'
          conn.puts "\033[36m\n=========* Commands *===============\n" +
                    "= Type 'exit' to leave the chatroom \n" +
                    "= /users to list all users         \n" +
                    "= /nick new_name to change nickname \n" +
                    "= /help to list all commands        \n" +
                    "====================================\033[0m"
        when '/users'
          conn.puts "Connected users: #{usernames.values.join(', ')}"
        when /^\/nick\s+(.+)/
          new_name = message.match(/^\/nick\s+(.+)/)[1]
          old_name = usernames[conn]
          usernames[conn] = new_name
          broadcast(clients, "#{old_name} (#{conn.peeraddr[2]})", "has changed their name to #{new_name}.", user_colours[conn])
        when 'exit'
          puts "Client disconnected: #{usernames[conn]}"
          clients.delete(conn)
          broadcast(clients, usernames[conn], "has left the chatroom.", user_colours[conn])
          conn.close
          break
        else
          # Broadcast the message with the assigned user colour
          broadcast(clients, usernames[conn], message, user_colours[conn])
        end
      rescue StandardError
        puts "Client disconnected: #{usernames[conn]}"
        clients.delete(conn)
        broadcast(clients, usernames[conn], "has left the chatroom.", user_colours[conn])
        conn.close
        break
      end
    end
  end
end
