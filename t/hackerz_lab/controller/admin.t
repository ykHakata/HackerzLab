use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

# データ構造をダンプする
use Data::Dumper;

# ハッカーシステムの読み込み
my $t = Test::Mojo->new('HackerzLab');

# admin コントローラーのテスト

# ルーティングの詳細テスト
subtest 'router' => sub {

    # 例： admin の場合
    # GET /admin -> ( controller => 'admin', action => 'index' );
    # GET /admin/ -> ( controller => 'admin', action => 'index' );
    $t->get_ok('/admin')->status_is(200);
    $t->get_ok('/admin/')->status_is(200);

    # GET /admin/menu -> ( controller => 'admin', action => 'index' );
    # GET /admin/menu/ -> ( controller => 'admin', action => 'index' );    
    $t->get_ok('/admin/menu')->status_is(200);
    $t->get_ok('/admin/menu/')->status_is(200);

};

# menu 画面の描画テスト
subtest 'menu display' => sub {
    $t->get_ok('/admin')->status_is(200)->content_like(qr/管理者機能一覧/i);
    $t->get_ok('/admin/')->status_is(200)->content_like(qr/管理者機能一覧/i);
    $t->get_ok('/admin/menu')->status_is(200)->content_like(qr/管理者機能一覧/i);
    $t->get_ok('/admin/menu/')->status_is(200)->content_like(qr/管理者機能一覧/i);
};


done_testing();

__END__

自由にコメントをかける
