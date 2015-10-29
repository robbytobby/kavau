class ProjectController < ApplicationController
  after_action :verify_authorized, except: :show
  after_action :verify_policy_scoped, only: :show

  def show
    @type = 'ProjectAddress'
    @addresses = policy_scope(ProjectAddress).order(:name)
    @accounts = policy_scope(Account).project_accounts
  end
end
