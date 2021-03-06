use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

# データ構造をダンプする
use Data::Dumper;

# ハッカーシステムテスト共通
use t::Util;
my $t = t::Util::init();

# auth コントローラーのテスト

# ルーティングの詳細テスト
subtest 'router' => sub {

    # 302リダイレクトレスポンスの許可
    $t->ua->max_redirects(1);

    # 例： login の場合
    # GET /admin/login -> ( controller => 'Admin::Auth', action => 'index' );
    $t->get_ok('/admin/login')->status_is(200);

    # POST /admin/login -> ( controller => 'Admin::Auth', action => 'login' );
    $t->post_ok('/admin/login')->status_is(200);

  # 例： logout の場合
  # POST /admin/logout -> ( controller => 'Admin::Auth', action => 'logout' );
    $t->post_ok('/admin/logout')->status_is(200);

   # GET /admin/logout -> ( controller => 'Admin::Auth', action => 'logout' );
    $t->get_ok('/admin/logout')->status_is(200);

    # 必ず戻すように ...
    $t->ua->max_redirects(0);
};

# menu 画面の描画テスト
subtest 'login logout display' => sub {

    # ログイン画面を表示
    $t->get_ok('/admin/login')->status_is(200)
        ->content_like(qr/管理者認証/i);

    # ログアウト実行完了画面描画
    $t->get_ok('/admin/logout')->status_is(200)
        ->content_like(qr/ログアウト/i);
};

# 認証機能のテスト
subtest 'auth check' => sub {

    subtest 'success login logout' => sub {

        # テスト用の staff データの存在確認
        my $row = $t->app->test_db->teng->single( 'staff', +{ id => 1 } );
        ok($row);
        my $login_id = $row->login_id;
        my $password = $row->password;

        # セッションの存在確認
        my $session_id
            = $t->app->build_controller( $t->tx )->session('login_id');
        is( $session_id, undef, 'session_id' );

        # ログインへのアクセス
        my $url    = '/admin/login';
        my $params = +{
            login_id => $login_id,
            password => $password,
        };

        # リクエスト (成功時 menu 画面)controller_class;
        $t->post_ok( $url => form => $params )->status_is(302);
        my $location_url = $t->tx->res->headers->location;
        $t->get_ok($location_url)->status_is(200);
        $t->text_is( 'strong', "$login_id ログインしました" );

        # セッションの存在確認
        $session_id = $t->app->build_controller( $t->tx )->session('login_id');
        ok( $session_id, 'session_id' );

        # ログアウトの実行
        $t->post_ok('/admin/logout')->status_is(302);
        $location_url = $t->tx->res->headers->location;
        $t->get_ok($location_url)->status_is(200);
        $t->text_is( 'h4', 'ログアウトしました' );

        # セッションの存在確認
        $session_id
            = $t->app->build_controller( $t->tx )->session('login_id');
        is( $session_id, undef, 'session_id' );
    };

    subtest 'failed login' => sub {

        my $row = $t->app->test_db->teng->single( 'staff', +{ id => 1 } );
        my $login_id = $row->login_id;
        my $password = $row->password;
        my $url         = '/admin/login';
        my $base_params = +{
            login_id => $login_id,
            password => $password,
        };

        my $common
            = '下記のフォームに正しく入力してください';
        my $blank_id       = 'ログインID';
        my $blank_pass     = 'ログインパスワード';
        my $not_exist_id   = 'ログインID(email)が存在しません';
        my $not_value_pass = 'ログインパスワードがちがいます';

        # login_id 入力されていない
        subtest 'blank login_id' => sub {
            my $params = +{ %{$base_params}, login_id => '', };
            $t->post_ok( $url => form => $params )->status_is(200);
            $t->text_is( 'strong', $common );
            $t->content_like(qr{\Q<dd>$blank_id</dd>\E});
            $t->content_unlike(qr{\Q<dd>$blank_pass</dd>\E});
            $t->content_unlike(qr{\Q<dd>$not_exist_id</dd>\E});
            $t->content_unlike(qr{\Q<dd>$not_value_pass</dd>\E});
        };

        # password 入力されていない
        subtest 'blank password' => sub {
            my $params = +{ %{$base_params}, password => '', };
            $t->post_ok( $url => form => $params )->status_is(200);
            $t->text_is( 'strong', $common );
            $t->content_unlike(qr{\Q<dd>$blank_id</dd>\E});
            $t->content_like(qr{\Q<dd>$blank_pass</dd>\E});
            $t->content_unlike(qr{\Q<dd>$not_exist_id</dd>\E});
            $t->content_unlike(qr{\Q<dd>$not_value_pass</dd>\E});
        };

        # login_id password 入力されていない
        subtest 'blank login_id password' => sub {
            my $params = +{
                %{$base_params},
                login_id => '',
                password => '',
            };
            $t->post_ok( $url => form => $params )->status_is(200);
            $t->text_is( 'strong', $common );
            $t->content_like(qr{\Q<dd>$blank_id</dd>\E});
            $t->content_like(qr{\Q<dd>$blank_pass</dd>\E});
            $t->content_unlike(qr{\Q<dd>$not_exist_id</dd>\E});
            $t->content_unlike(qr{\Q<dd>$not_value_pass</dd>\E});
        };

        # ログインID が存在しない
        subtest 'not exist login_id' => sub {
            my $params
                = +{ %{$base_params}, login_id => 'hackerz@gmail.com', };
            $t->post_ok( $url => form => $params )->status_is(200);
            $t->text_is( 'strong', $common );
            $t->content_unlike(qr{\Q<dd>$blank_id</dd>\E});
            $t->content_unlike(qr{\Q<dd>$blank_pass</dd>\E});
            $t->content_like(qr{\Q<dd>$not_exist_id</dd>\E});
            $t->content_unlike(qr{\Q<dd>$not_value_pass</dd>\E});
        };

        # パスワードが違う
        subtest 'not value password' => sub {
            my $params = +{ %{$base_params}, password => '12345', };
            $t->post_ok( $url => form => $params )->status_is(200);
            $t->text_is( 'strong', $common );
            $t->content_unlike(qr{\Q<dd>$blank_id</dd>\E});
            $t->content_unlike(qr{\Q<dd>$blank_pass</dd>\E});
            $t->content_unlike(qr{\Q<dd>$not_exist_id</dd>\E});
            $t->content_like(qr{\Q<dd>$not_value_pass</dd>\E});
        };
    };

    #  入力フォームの存在確認
    $t->get_ok('/admin/login')->status_is(200);
    my $tags = [ 'input[name=login_id]', 'input[name=password]', ];
    for my $tag ( @{$tags} ) {
        $t->element_exists( $tag, "element check $tag" );
    }
};

# ログインセッションで保護されたページ
subtest 'session site' => sub {

    # ログインしていない状態で menu ページアクセス
    my $url = '/admin/menu';
    $t->get_ok($url)->status_is(302);

    # リダイレクト先の確認 (login 誘導)
    my $location_url = '/admin/login';
    $t->header_is( location => $location_url );

    # ログイン情報がないことを確認
    my $login_staff = $t->app->login_staff;
    is( $login_staff, undef, 'check login staff' );

    # ログイン状態でアクセス

    # テスト用の staff データの存在確認
    my $row = $t->app->test_db->teng->single( 'staff', +{ id => 1 } );
    ok($row);

    # ログインへのアクセス
    $url = '/admin/login';
    my $params = +{
        login_id => $row->login_id,
        password => $row->password,
    };

    # 302リダイレクトレスポンスの許可
    $t->ua->max_redirects(1);
    $t->post_ok( $url => form => $params )->status_is(200);
    $t->content_like(qr{\Qログインしました\E});
    $t->ua->max_redirects(0);

    # ログイン状態で menu ページアクセス
    $url = '/admin/menu';
    $t->get_ok($url)->status_is(200);

    # ログイン情報取得のヘルパーメソッド
    $login_staff = $t->app->login_staff;
    ok( $login_staff, 'check login staff' );
    is( $row->id,       $login_staff->id,       'check login staff' );
    is( $row->login_id, $login_staff->login_id, 'check login staff' );
};

done_testing();

__END__

Auth コントローラーのテスト
