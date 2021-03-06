use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

# データ構造をダンプする
use Data::Dumper;

# ハッカーシステムテスト共通
use t::Util;
my $t = t::Util::init();

# etc/conf
subtest 'plugin conf' => sub {
    my $conf = $t->app->config;
    is( $conf->{mode}, $t->app->mode, 'conf test' );
};

# コマンドスクリプト用のスペース
subtest 'namespaces commands' => sub {
    my $namespaces = $t->app->commands->namespaces;
    my @names      = qw{Mojolicious::Command HackerzLab::Command};
    for my $name ( @{$namespaces} ) {
        my $ok = grep { $name eq $_ } @names;
        my $label = $name . ' namespaces ok!';
        ok( $ok, $label );
    }
};

# ルーティングのテスト
subtest 'router' => sub {

    # 302リダイレクトレスポンスの許可
    $t->ua->max_redirects(1);

    # http://hackerzlab.com/ (告知サイト)
    $t->get_ok('/index.html')->status_is(200);
    $t->get_ok('/')->status_is(200);

    # データの中身をダンプする
    # warn 'menu-------: ' , Dumper($t->tx->res->body);

    # http://hackerzlab.com/training/ (トレーニングサイト)
    $t->get_ok('/training/')->status_is(200);

    # http://hackerzlab.com/admin/ (管理画面)
    $t->get_ok('/admin/')->status_is(200);

    # 例： login の場合
    # ログイン画面を表示
    # GET /admin/login -> ( controller => 'auth', action => 'index' );
    $t->get_ok('/admin/login')->status_is(200);

    # ログイン実行
    # POST /admin/login -> ( controller => 'auth', action => 'login' );
    $t->post_ok('/admin/login')->status_is(200);

    # 例： logout の場合
    # ログアウト実行
    # POST /admin/logout -> ( controller => 'auth', action => 'logout' );
    $t->post_ok('/admin/logout')->status_is(200);

    # ログアウト実行完了画面描画
    # GET /admin/logout -> ( controller => 'auth', action => 'logout' );
    $t->get_ok('/admin/logout')->status_is(200);

    # 必ず戻すように ...
    $t->ua->max_redirects(0);
};

# フォルダ構造(コントローラーの中身)
# lib/HackerzLab/
# lib/HackerzLab/HackerzLab.pm
# lib/HackerzLab/Controller/
# lib/HackerzLab/Controller/Admin.pm
# lib/HackerzLab/Controller/Admin
# lib/HackerzLab/Controller/Admin/Auth.pm
# lib/HackerzLab/Controller/Example.pm
# lib/HackerzLab/Controller/Training.pm
# lib/HackerzLab/Controller/Training

# コントローラーのファイルの存在確認
subtest 'controller files exist' => sub {
    my $home = $t->app->home();
    my $files = $home->list_files('lib/HackerzLab/Controller/');
    my $test_files = [qw{Admin.pm Training.pm Admin/Auth.pm}];
    for my $file ( @{$test_files} ){
        my $text = grep { $_ eq $file } @{$files};
        is( $text, 1, "file name test $file" );
    }
};

done_testing();
