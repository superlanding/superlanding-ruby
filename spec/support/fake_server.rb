require "socket"

# 最小的本機 HTTP server（只綁 127.0.0.1、隨機 port），讓測試能走完整的
# RestClient -> Net::HTTP 流程，但不會連到任何外部網路。
class FakeServer
  attr_reader :requests, :port

  Request = Struct.new(:method, :target, :path, :query, :body)

  def initialize(status: 200, body: "[]")
    @status = status
    @body = body
    @requests = []
    @server = TCPServer.new("127.0.0.1", 0)
    @port = @server.addr[1]
    @thread = Thread.new { serve }
  end

  def url
    "http://127.0.0.1:#{port}"
  end

  def stop
    @server.close unless @server.closed?
    @thread.join(1)
  end

  def self.run(**opts)
    server = new(**opts)
    yield server
  ensure
    server.stop
  end

  private

  def serve
    loop do
      client = @server.accept
      handle(client)
    end
  rescue IOError, Errno::EBADF
    nil
  end

  def handle(client)
    request_line = client.gets
    method, target, = request_line.split(" ")
    headers = {}
    while (line = client.gets) && line != "\r\n"
      key, value = line.split(":", 2)
      headers[key.downcase] = value.strip
    end
    body = headers["content-length"] ? client.read(headers["content-length"].to_i) : ""
    path, query = target.split("?", 2)
    @requests << Request.new(method, target, path, query.to_s, body)

    reason = { 200 => "OK", 401 => "Unauthorized", 500 => "Internal Server Error" }.fetch(@status, "Status")
    client.write "HTTP/1.1 #{@status} #{reason}\r\n" \
                 "Content-Type: application/json\r\n" \
                 "Content-Length: #{@body.bytesize}\r\n" \
                 "Connection: close\r\n\r\n#{@body}"
  ensure
    client.close
  end
end
