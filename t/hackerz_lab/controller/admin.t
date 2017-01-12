use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

# データ構造をダンプする
use Data::Dumper;

# ハッカーシステムテスト共通
use t::Util;
my $t = t::Util::init();

# admin コントローラーのテスト

# ルーティングの詳細テスト
subtest 'router' => sub {

    # 管理者ログイン実行
    t::Util::login_admin($t);

    # 例： admin の場合
    # GET /admin -> ( controller => 'admin', action => 'index' );
    # GET /admin/ -> ( controller => 'admin', action => 'index' );
    $t->get_ok('/admin')->status_is(200);
    $t->get_ok('/admin/')->status_is(200);

    # GET /admin/menu -> ( controller => 'admin', action => 'index' );
    # GET /admin/menu/ -> ( controller => 'admin', action => 'index' );
    $t->get_ok('/admin/menu')->status_is(200);
    $t->get_ok('/admin/menu/')->status_is(200);

    # 管理者ログアウト実行
    t::Util::logout_admin($t);
};

# menu 画面の描画テスト
subtest 'menu display' => sub {

    # 管理者ログイン実行
    t::Util::login_admin($t);

    $t->get_ok('/admin')->status_is(200)->content_like(qr/管理者機能一覧/i);
    $t->get_ok('/admin/')->status_is(200)->content_like(qr/管理者機能一覧/i);
    $t->get_ok('/admin/menu')->status_is(200)->content_like(qr/管理者機能一覧/i);
    $t->get_ok('/admin/menu/')->status_is(200)->content_like(qr/管理者機能一覧/i);

    # 管理者ログアウト実行
    t::Util::logout_admin($t);
};


done_testing();

__END__

自由にコメントをかける
