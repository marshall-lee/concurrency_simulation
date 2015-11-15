ConcurrencySimulation.new do |sim|
  sim.add_process do
    _
    _ { puts '2' }
    _
    _ { puts '4' }
  end

  sim.add_process do
    _ { puts '1' }
    _
    _ { puts '3' }
    _
  end
end
