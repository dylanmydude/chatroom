require 'socket'

server = TCPServer.new('0.0.0.0', 12345) # Bind to all interfaces on port 12345
clients = [] # Array to keep track of connected clients

puts "Chatroom server started. Waiting for clients to connect..."

loop do
  # Accept a new client connection
  client = server.accept
  clients << client
  puts "New client connected: #{client.peeraddr[2]}"

  # Handle the client in a new thread
  Thread.new(client) do |conn|
    conn.puts "Welcome to the chatroom!"
    
    # Listen for incoming messages from this client
    loop do
      begin
        message = conn.gets.chomp
        puts "Received: #{message} from #{conn.peeraddr[2]}"
        
        # Broadcast the message to all other clients
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
