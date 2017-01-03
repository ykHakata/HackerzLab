use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

# データ構造をダンプする
use Data::Dumper;

# ハッカーシステムの読み込み
my $t = Test::Mojo->new('HackerzLab');

# auth コントローラーのテスト

# ルーティングの詳細テスト
subtest 'router' => sub {

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

};

# menu 画面の描画テスト
subtest 'login logout display' => sub {
  # ログイン画面を表示
  $t->get_ok('/admin/login')->status_is(200)->content_like(qr/管理者認証/i);
  
  # ログアウト実行完了画面描画
  $t->get_ok('/admin/logout')->status_is(200)->content_like(qr/ログアウト/i);
};


done_testing();

__END__

Auth コントローラーのテスト
