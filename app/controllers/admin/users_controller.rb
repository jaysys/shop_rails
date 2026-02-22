module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show update destroy]

    def index
      @users = User.order(created_at: :desc)
    end

    def show
      @orders = @user.orders.where(status: "paid").order(created_at: :desc)
    end

    def update
      make_admin = ActiveModel::Type::Boolean.new.cast(params.expect(user: [:admin])[:admin])

      if @user == current_user && !make_admin
        redirect_to admin_user_path(@user), alert: "자기 자신의 관리자 권한은 해제할 수 없습니다.", status: :see_other
        return
      end

      if @user.update(admin: make_admin)
        redirect_to admin_user_path(@user), notice: "권한을 변경했습니다.", status: :see_other
      else
        redirect_to admin_user_path(@user), alert: @user.errors.full_messages.to_sentence, status: :see_other
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "자기 자신은 삭제할 수 없습니다.", status: :see_other
        return
      end

      @user.destroy!
      redirect_to admin_users_path, notice: "사용자를 삭제했습니다.", status: :see_other
    end

    private

    def set_user
      @user = User.find(params.expect(:id))
    end
  end
end
