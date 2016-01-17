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

def permits(permited_actions, options = {})
  options.default=[]
  permited_actions = all_actions - options[:except]  if permited_actions == :all
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

def forbids(forbidden_actions, options = {})
  options.default={}
  
  forbidden_actions = all_actions - options[:except] if forbidden_actions == :all
  forbidden_actions = [] if forbidden_actions == :none

  forbidden_actions.each do |action|
    it "does not permit :#{action}" do
      should_not permit(action)
    end
  end
  
  (all_actions - forbidden_actions). each do |action|
    it "permits #{action}" do
      should permit(action)
    end
  end
end

def all_actions
  action_methods.map{|m| m.to_s.gsub(/\?/,'').to_sym}
end

def action_methods
  public_policy_methods.
    select{|m| m if m.to_s.match(/\?$/)}.
    select{|m| m if !m.to_s.match(/^permitted/)}
end

def public_policy_methods
  anchestors.map{|a| a.public_instance_methods(false)}.flatten.uniq
end

def anchestors
  self.described_class.ancestors.select{|i| ApplicationPolicy.descendants.include?(i)} + [ApplicationPolicy]
end

