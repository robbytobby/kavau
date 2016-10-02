class FundsController < ApplicationController
  include LoadAuthorized

  respond_to :html

  def new
    respond_with @fund 
  end

  def edit
    respond_with @fund 
  end

  def create
    @fund.save
    respond_with @fund, location: project_path
  end

  def update
    @fund.update permitted_params
    respond_with @fund, location: project_path
  end

  def destroy
    @fund.destroy
    respond_with @fund, location: project_path
  end
end
