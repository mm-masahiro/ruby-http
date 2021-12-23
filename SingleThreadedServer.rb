require 'socket'

class SingleThreadedServer
  PORT = ENV.fetch('PORT', 3300)
	HOST = ENV.fetch('HOST', '127.0.0.1').freeze

	SOCKET_READ_BACKLOG = ENV.fetch('TCP_BACKLOG', 12).to_i

	attr_accessor :app

	def initialize(app)
		self.app = app
	end

	def start
		socket = listen_on_socket

		loop do
			conn, _addr_info = socket.accept
			request = RequestParser.call(conn)
			status, headers, body = app.call(request)
			HttpResponder.call(conn, status, headers, body)

		rescue => e
			puts e.message
		ensure
			conn&.close
		end
	end
end

SingleThreadedServer(SomeRackApp.new).start
