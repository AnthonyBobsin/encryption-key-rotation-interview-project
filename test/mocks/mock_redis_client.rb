class MockRedisClient
  attr_accessor :get_response, :set_response, :del_response

  def get(key)
    get_response
  end

  def set(key, val, opts = {})
    set_response
  end

  def del(key)
    del_response
  end
end