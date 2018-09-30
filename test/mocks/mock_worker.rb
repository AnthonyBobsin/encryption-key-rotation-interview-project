class MockWorker
  Jobs = Struct.new(:size)

  class << self
    attr_accessor :job_size

    def jobs
      Jobs.new(job_size || 0)
    end
  end
end