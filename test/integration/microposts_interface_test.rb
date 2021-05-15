require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select "div.pagination"
    # 画像ファイル選択
    assert_select "input[type=file]"

    # 無効な送信 => models/micropost.rb バリデーションの部分
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select "div#error_explanation"
    assert_select "a[href=?]", "/?page=2"  # 正しいページネーションリンク

    # 有効な送信 => controllers/microposts_controllers.rb create
    content = "This micropost really ties the room together"
    image = fixture_file_upload("test/fixtures/kitten.jpg", "image/jpeg")
    assert_difference "Micropost.count", 1 do
      post microposts_path, params: { micropost: { content: content,
                                                  image: image } }
    end
    assert assigns(:micropost).image.attached?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

    # 投稿を削除する => views/_micropost.html.erb delete リンク部
    assert_select "a", text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end

    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認）
    # => views/_micropost.html.erb if current_user?(micropost.user)
    get user_path(users(:archer))
    assert_select "a", text: "delete", count: 0
  end

  # サイドバーの投稿数カウントテスト
  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body

    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body

    # 投稿数により micropost が複数形に変化する
    (1..3).each do |posted_times|
      other_user.microposts.create!(content: "post#{posted_times}")
      get root_path
      posted_count_message = "#{posted_times} micropost"
      posted_count_message << "s" if 1 < posted_times
      assert_match posted_count_message, response.body
    end
  end
end
