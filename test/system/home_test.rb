# frozen_string_literal: true

require 'application_system_test_case'

class HomeTest < ApplicationSystemTestCase
  test 'GET / without sign in' do
    logout
    visit '/'
    assert_equal 'FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'GET /' do
    visit_with_auth '/', 'komagata'
    assert_equal 'ダッシュボード | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'verify message presence of github_account registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'GitHubアカウントを登録してください。'

    # GitHub との連携処理を update! で代用
    users(:hajime).update!(github_account: 'hajime')
    visit '/'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'GitHubアカウントを登録してください。'
  end

  test 'verify message presence of discord_account registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'Discordアカウントを登録してください。'

    visit '/current_user/edit'
    fill_in 'user[discord_account]', with: 'hajime#1111'
    click_button '更新する'
    visit '/'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'Discordアカウントを登録してください。'
  end

  test 'verify message presence of avatar registration' do
    visit_with_auth '/', 'hajime'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'ユーザーアイコンを登録してください。'

    visit '/current_user/edit'
    file_path = Rails.root.join('test/fixtures/files/users/avatars/default.jpg')
    attach_file 'user[avatar]', file_path, make_visible: true
    click_button '更新する'
    visit '/'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'ユーザーアイコンを登録してください。'
  end

  test 'verify message presence of tags registration' do
    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'タグを登録してください。'

    visit '/current_user/edit'
    tag_input = find('.ti-new-tag-input')
    tag_input.set '猫'
    tag_input.native.send_keys :return
    click_button '更新する'
    visit '/'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'タグを登録してください。'
  end

  test 'verify message presence of after_graduation_hope registration' do
    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'

    visit '/current_user/edit'
    fill_in 'user[after_graduation_hope]', with: 'IT ジェンダーギャップ問題を解決するアプリケーションを作る事業に、エンジニアとして携わる。'
    click_button '更新する'
    visit '/'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'
  end

  test 'verify message presence of blog_url registration' do
    users(:hatsuno).update!(blog_url: '') # 確認のために削除
    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_text 'ブログURLを登録してください。'

    visit '/current_user/edit'
    fill_in 'user[blog_url]', with: 'http://hatsuno.org'
    click_button '更新する'
    visit '/'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text 'ブログURLを登録してください。'
  end

  test 'not show messages of required field' do
    user = users(:hatsuno)
    # hatsuno の未入力項目を登録
    user.update!(
      tag_list: ['猫'],
      after_graduation_hope: 'IT ジェンダーギャップ問題を解決するアプリケーションを作る事業に、エンジニアとして携わる。',
      discord_account: 'hatsuno#1234'
    )
    path = Rails.root.join('test/fixtures/files/users/avatars/hatsuno.jpg')
    user.avatar.attach(io: File.open(path), filename: 'hatsuno.jpg')

    visit_with_auth '/', 'hatsuno'
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    assert_no_text '未入力の項目'
  end

  test 'show latest announcements on dashboard' do
    visit_with_auth '/', 'hajime'
    assert_text '後から公開されたお知らせ'
    assert_no_text 'wipのお知らせ'
  end

  test 'show the Nico Nico calendar for students' do
    visit_with_auth '/', 'hajime'
    assert_text 'ニコニコカレンダー'
  end

  test 'show the Nico Nico calendar for graduates' do
    visit_with_auth '/', 'sotugyou'
    assert_text 'ニコニコカレンダー'
  end

  test 'not show the Nico Nico calendar for administrators' do
    visit_with_auth '/', 'komagata'
    assert_no_text 'ニコニコカレンダー'
  end

  test 'show the Nico Nico calendar for trainees' do
    visit_with_auth '/', 'kensyu'
    assert_text 'ニコニコカレンダー'
  end

  test 'show Nico Nico calendar page that matches URL params' do
    visit_with_auth '/?niconico_calendar=2020-01', 'hajime'
    find('.niconico-calendar-nav').assert_text '2020年1月'
  end

  test "show current month's page of Nico Nico calendar when future date is specified in URL params" do
    visit_with_auth "/?niconico_calendar=#{Time.current.next_month.strftime('%Y-%m')}", 'hajime'
    find('.niconico-calendar-nav').assert_text Time.current.strftime('%Y年%-m月')
  end

  test 'keep Nico Nico calendar page even when leave dashboard' do
    visit_with_auth '/', 'hajime'
    find('.niconico-calendar-nav__previous').click
    find('.niconico-calendar-nav').assert_text 1.month.ago.strftime('%Y年%-m月')
    find('.niconico-calendar').click_link href: /reports/, match: :first
    go_back
    find('.niconico-calendar-nav').assert_text 1.month.ago.strftime('%Y年%-m月')
    assert_current_path(/niconico_calendar=#{1.month.ago.strftime('%Y-%m')}/)
  end

  test 'show the grass' do
    visit_with_auth '/', 'hajime'
    assert_text '学習時間'
  end

  test 'show test events on dashboard' do
    travel_to Time.zone.local(2017, 4, 1, 10, 0, 0) do
      visit_with_auth '/', 'komagata'
      assert_text '直近イベントの表示テスト用(当日)'
      assert_text '直近イベントの表示テスト用(翌日)'
    end
  end

  test 'show job events on dashboard for only job seeker' do
    travel_to Time.zone.local(2017, 4, 1, 10, 0, 0) do
      visit_with_auth '/', 'jobseeker'
      assert_text '直近イベントの表示テスト用(当日)'
      assert_text '直近イベントの表示テスト用(翌日)'
      assert_text '就職関係かつ直近イベントの表示テスト用'
      logout

      visit_with_auth '/', 'komagata'
      assert_text '直近イベントの表示テスト用(当日)'
      assert_text '直近イベントの表示テスト用(翌日)'
      assert_no_text '就職関係かつ直近イベントの表示テスト用'
    end
  end
end
