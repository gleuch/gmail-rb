class Error < StandardError

  ServerError = Class.new(self)
  Unauthorized = Class.new(self)

end