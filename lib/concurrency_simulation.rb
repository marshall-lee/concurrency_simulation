require 'concurrent'

class ConcurrencySimulation
  def initialize
    @processes = []
    if block_given?
      yield self
      run
    end
  end

  def add_process(&block)
    @processes << Process.new.tap do |p|
      p.instance_eval(&block)
    end
  end

  def processes_count
    @processes.length
  end

  def run
    barrier = Concurrent::CyclicBarrier.new(processes_count)
    latch = Concurrent::CountDownLatch.new(processes_count)
    max_blocks = @processes.map(&:blocks_count).max
    @processes.each do |p|
      p.async.run(max_blocks, barrier, latch)
    end
    latch.wait
  end

  class Process
    include Concurrent::Async

    class Context
    end

    def initialize
      @blocks = []
    end

    def blocks_count
      @blocks.length
    end

    def _(&block)
      block ||= proc { }
      @blocks << block
    end

    def run(max_count, barrier, latch)
      context = Context.new
      barrier.wait
      @blocks.each do |block|
        context.instance_eval(&block)
        barrier.wait
      end
      (max_count - blocks_count).times do
        barrier.wait
      end
      latch.count_down
    end
  end
end
