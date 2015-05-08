class HttpResponse
  attr_accessor :request, :headers, :body
  
  def initialize(request, headers = {}, body = "")
    @request = request
    @headers = headers
    @body = body
  end
end