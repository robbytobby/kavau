class UsersController < ApplicationController
  before_action :clear_password_params, unless: -> { :password_params_set? }
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  responders :collection

  def index
    @users = policy_scope(User).order(:first_name)
    authorize(@users)
    respond_with @users
  end

  def show
    respond_with @user
  end

  def new
    @user = User.new
    authorize @user
    respond_with @user
  end

  def edit
    respond_with @user
  end

  def create
    @user = User.new(user_params)
    authorize @user
    @user.save
    respond_with @user
  end

  def update
    @user.update(user_params)
    respond_with @user
  end

  def destroy
    @user.destroy
    respond_with @user
  end

  private
    def set_user
      @user = User.find(params[:id])
      authorize @user
    end

    def user_params
      params.require(:user).permit(policy(@user || User.new).permitted_params)
    end

    def clear_password_params
      params[:user].except!(:password, :password_confirmation)
    end

    def password_params_set?
      return false unless params[:user]
      ! params[:user].slice(:password, :password_confirmation).values.all?(&:blank?)
    end
end
