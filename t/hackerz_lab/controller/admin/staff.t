use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

# ハッカーシステムテスト共通
use t::Util;
my $t = t::Util::init();

# staff コントローラーのテスト
subtest 'router' => sub {
    $t->get_ok('/admin/login')->status_is(200);

    # 302リダイレクトレスポンスの許可
    $t->ua->max_redirects(1);

    $t->get_ok('/admin/staff')->status_is(200);
    $t->get_ok('/admin/staff/search')->status_is(200);
    $t->get_ok('/admin/staff/create')->status_is(200);
    $t->get_ok('/admin/staff/10')->status_is(200);
    $t->get_ok('/admin/staff/10/edit')->status_is(200);
    $t->post_ok('/admin/staff')->status_is(200);
    $t->post_ok('/admin/staff/10/update')->status_is(200);
    $t->post_ok('/admin/staff/10/remove')->status_is(200);

    # 必ず戻すように ...
    $t->ua->max_redirects(0);
};

done_testing();

__END__

# GET:  /staff           -> ( controller => 'Staff', action => 'index' );  # 一覧画面 (検索入力画面含み)
# GET:  /staff/search    -> ( controller => 'Staff', action => 'search' ); # 検索実行
# GET:  /staff/create    -> ( controller => 'Staff', action => 'create' ); # 新規登録画面表示
# GET:  /staff/10        -> ( controller => 'Staff', action => 'show' );   # 個別詳細画面
# GET:  /staff/10/edit   -> ( controller => 'Staff', action => 'edit' );   # 個別編集入力画面
# POST: /staff           -> ( controller => 'Staff', action => 'store' );  # 新規登録実行
# POST: /staff/10/update -> ( controller => 'Staff', action => 'update' ); # 個別編集実行
# POST: /staff/10/remove -> ( controller => 'Staff', action => 'remove' ); # 個別削除実行
