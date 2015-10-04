class ProjectController < ApplicationController
  respond_to :html

  def show
    @addresses = ProjectAddress.all

  end
end

