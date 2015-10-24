class UsersController < ApplicationController
  before_action :clear_password_params, unless: -> { :password_params_set? }
  include LoadAuthorized
  responders :collection

  def index
    @users = @users.order(:first_name)
    respond_with @users
  end

  def show
    respond_with @user
  end

  def new
    respond_with @user
  end

  def edit
    respond_with @user
  end

  def create
    @user.save
    respond_with @user
  end

  def update
    @user.update(permitted_params)
    respond_with @user
  end

  def destroy
    @user.destroy
    respond_with @user
  end

  private
    def clear_password_params
      params[:user].except!(:password, :password_confirmation)
    end

    def password_params_set?
      return false unless params[:user]
      ! params[:user].slice(:password, :password_confirmation).values.all?(&:blank?)
    end
end
