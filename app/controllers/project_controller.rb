class ProjectController < ApplicationController
  respond_to :html
  after_action :verify_authorized, :except => :show
  after_action :verify_policy_scoped, :only => :show

  def show
    @addresses = policy_scope(ProjectAddress)
  end
end

