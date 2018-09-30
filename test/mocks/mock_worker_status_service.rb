class MockWorkerStatusService
  def initialize
    @locked = false
  end

  def lock_available?
    !(@locked)
  end

  def lock!
    @locked = true
  end

  def unlock!
    @locked = false
  end
end