class SessionsController < ApplicationController
  def new
  end

  def create
    email = params.dig(:session, :email).to_s.strip.downcase
    password = params.dig(:session, :password).to_s

    user = User.find_by(email: email)

    if user&.authenticate(password)
      session[:user_id] = user.id
      redirect_to root_path, notice: "로그인되었습니다."
    else
      flash.now[:alert] = "이메일 또는 비밀번호가 올바르지 않습니다."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "로그아웃되었습니다."
  end
end
