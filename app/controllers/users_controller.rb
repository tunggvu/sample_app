class UsersController < ApplicationController
  before_action :logged_in_user, except: [:show, :new, :create]
  before_action :verify_user, only: [:edit, :update]
  before_action :verify_admin, only: :destroy
  before_action :load_user, only: [:show, :edit, :update]

  def index
    @users = User.select(:id, :name, :email).paginate page: params[:page],
      per_page: Settings.page.per_page
  end

  def show
    @microposts = @user.microposts.paginate page: params[:page],
      per_page: Settings.page.per_page
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".activate"
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = t ".updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    load_user
    @user.destroy ? flash[:success] = t(".delete") : flash[:danger] = t(".error")
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def load_user
    @user = User.find_by id: params[:id]
    unless @user
      flash[:danger] = t ".error"
      redirect_to users_url
    end
  end
end
