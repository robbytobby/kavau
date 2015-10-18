def do_not(action, klass)
  allow_any_instance_of(klass).to receive(action).and_return(false)
  allow_any_instance_of(klass).to receive(:errors).and_return(base: 'Failure')
end

