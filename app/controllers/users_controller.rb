class UsersController < ApplicationController
  before_action :clear_password_params, only: :update
  include LoadAuthorized
  include Searchable
  responders :collection

  def index
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
    respond_with @user, location: after_action_path
  end

  def destroy
    @user.destroy
    respond_with @user
  end

  private
    def default_sort
      { 's' => ['first_name asc', 'name asc'] }
    end

    def clear_password_params
      return if password_params_set?
      params[:user].except!(:password, :password_confirmation)
    end

    def password_params_set?
      return false unless params[:user]
      !password_params.values.all?(&:blank?)
    end

    def password_params
      params[:user].slice(:password, :password_confirmation)
    end

    def after_action_path
      session[:back_url]
    end
end
