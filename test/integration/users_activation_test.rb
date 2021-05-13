require "test_helper"

class UsersActivationTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @non_activated_user = users(:red)
  end

  test "index only activated user" do
    log_in_as(@user)
    get users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", user_path(@non_activated_user), count: 0
  end

  test "show only activated user" do
    log_in_as(@user)
    get user_path(@user)
    get user_path(@non_activated_user)
    assert_redirected_to root_url
  end
end
