class PromoteFirstUserToAdminIfNone < ActiveRecord::Migration[8.1]
  def up
    return if User.where(admin: true).exists?

    first_user = User.order(:id).first
    first_user&.update_column(:admin, true)
  end

  def down
  end
end
