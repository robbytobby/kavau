def do_not(action, klass, error_attr = :base)
  allow_any_instance_of(klass).to receive(action).and_return(false)
  allow_any_instance_of(klass).to receive(:errors).and_return(error_attr => 'Failure')
end

