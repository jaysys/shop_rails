class UsersController < ApplicationController
  before_action :require_login, only: %i[edit update destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.admin = true if User.count.zero?

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "회원가입이 완료되었습니다."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    attrs = user_update_params.to_h
    if attrs["password"].blank?
      attrs.except!("password", "password_confirmation")
    end

    if @user.update(attrs)
      redirect_to edit_profile_path, notice: "프로필이 수정되었습니다.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    user = current_user

    if user.admin? && User.where(admin: true).count == 1
      redirect_to edit_profile_path, alert: "마지막 관리자 계정은 탈퇴할 수 없습니다.", status: :see_other
      return
    end

    user.destroy!
    reset_session
    redirect_to root_path, notice: "회원 탈퇴가 완료되었습니다.", status: :see_other
  end

  private

  def user_params
    params.expect(user: [:name, :email, :password, :password_confirmation])
  end

  def user_update_params
    params.expect(user: [:name, :email, :password, :password_confirmation])
  end
end
