class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  responders :collection

  def index
    @users = policy_scope(User)
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
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
      authorize @user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      params.require(:user).permit(policy(@user || User.new).permitted_params)
    end
end
