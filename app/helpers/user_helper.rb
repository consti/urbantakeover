module UserHelper
  def can_edit_spot?
    logged_in? and current_user.is_admin?
  end
end