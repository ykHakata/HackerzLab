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
  $t->get_ok('/admin/login')->status_is(200)->content_like(qr/管理者認証/i);

  # ログアウト実行完了画面描画
  $t->get_ok('/admin/logout')->status_is(200)->content_like(qr/ログアウト/i);
};

# 認証機能のテスト
subtest 'auth check' => sub {

    # テスト用の staff データの存在確認
    my $row = $t->app->db->teng->single( 'staff', +{ id => 1 } );
    ok($row);

    # ログインへのアクセス
    my $url    = '/admin/login';
    my $params = +{
        email    => $row->login_id,
        password => $row->password,
    };

    # セッションの存在確認
    my $session_id = $t->app->build_controller( $t->tx )->session('login_id');
    is( $session_id, undef, 'session_id' );

    # 302リダイレクトレスポンスの許可
    $t->ua->max_redirects(1);

    # リクエスト (成功時 menu 画面)controller_class;
    $t->post_ok( $url => form => $params )->status_is(200);

    # 遷移先の画面でログイン成功のメッセージ
    $t->content_like(qr{\Qログインしました\E});

    # 必ず戻すように ...
    $t->ua->max_redirects(0);

    # セッションの存在確認
    $session_id = $t->app->build_controller( $t->tx )->session('login_id');
    ok( $session_id, 'session_id' );

    # ログアウトの実行
    $t->post_ok('/admin/logout')->status_is(302);

    # リダイレクト先の確認
    my $location_url = '/admin/logout';
    $t->header_is( location => $location_url );

    # リダイレクト先でアクセス後、セッション確認
    $t->get_ok($location_url)->status_is(200);
    $session_id = $t->app->build_controller( $t->tx )->session('login_id');
    is( $session_id, undef, 'session_id' );
};

done_testing();

__END__

Auth コントローラーのテスト
