RSpec::Matchers.define :permit do |action|
  match do |policy|
    policy.public_send("#{action}?")
  end

  failure_message do |policy|
    "#{policy.class} does not permit #{action} on #{policy.record} for #{policy.user.inspect}."
  end

  failure_message_when_negated do |policy|
    "#{policy.class} does not forbid #{action} on #{policy.record} for #{policy.user.inspect}."
  end
end

def permits(permited_actions)
  
  all_actions = [:index, :show, :new, :create, :edit, :update, :destroy]
  
  permited_actions = all_actions if permited_actions == :all
  permited_actions = [] if permited_actions == :none

  permited_actions.each do |action|
    it "permits :#{action}" do
      should permit(action)
    end
  end
  
  (all_actions - permited_actions). each do |action|
    it "does not permit #{action}" do
      should_not permit(action)
    end
  end
end
