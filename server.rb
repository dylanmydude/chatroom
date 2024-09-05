require 'socket'

server = TCPServer.new('0.0.0.0', 12345) # Bind
clients = []

puts "Chatroom server started. Waiting for clients to connect..."

loop do
 
  client = server.accept
  clients << client
  puts "New client connected: #{client.peeraddr[2]}"

  Thread.new(client) do |conn|
    conn.puts "Welcome to the chatroom!"
    
    loop do
      begin
        message = conn.gets.chomp
        puts "Received: #{message} from #{conn.peeraddr[2]}"
        
        clients.each do |c|
          c.puts "#{conn.peeraddr[2]} says: #{message}" unless c == conn
        end
        
      rescue StandardError
        puts "Client disconnected: #{conn.peeraddr[2]}"
        clients.delete(conn)
        conn.close
        break
      end
    end
  end
end
