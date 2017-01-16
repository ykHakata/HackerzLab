use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper url_escape url_unescape encode};

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

# 一覧画面 (検索入力画面含み)
subtest 'index' => sub {

    # ログインせずにリクエスト (リダイレクトされる)
    $t->get_ok('/admin/staff')->status_is(302);

    # ログイン画面へ誘導
    $t->header_is( location => '/admin/login' );

    # ログインをする
    t::Util::login_admin($t);

    # 一覧を表示できる
    $t->get_ok('/admin/staff')->status_is(200);

# タイトルと確実に表示される 2件目のみを確認テスト
# 1件目はログインしているので、ヘッダーに表示されてる
# @ は特別な意味があるので、一度文字列にして
    my $words = [ '絞り込み検索', 'hackerz.lab.sudo@gmail.com' ];
    for my $word ( @{$words} ) {
        $t->content_like( qr{\Q$word\E}, 'content check' );
    }

    # ページャーの指定 id -> 7 (最初の 5件にはない)
    $t->get_ok('/admin/staff?page=2')->status_is(200);
    $words = [ '絞り込み検索', 'hackerz.lab.karamatu@gmail.com' ];
    for my $word ( @{$words} ) {
        $t->content_like( qr{\Q$word\E}, 'content check' );
    }

    # ログアウトする
    t::Util::logout_admin($t);

    # ログアウトの確認
    $t->get_ok('/admin/staff')->status_is(302);
    $t->header_is( location => '/admin/login' );
};

# 検索実行
subtest 'search' => sub {

    # ログインをする
    t::Util::login_admin($t);

# stash->{staffs} を定義するまえにリクエストすると 500 になるはず
# こちらテストコードでは再現できない、テストコードは完璧ではないのだ
    $t->get_ok('/admin/staff/search')->status_is(200);

    # 特に値をしてせずに検索の場合、初期表示と同じ
    my $words = [ '絞り込み検索', 'hackerz.lab.sudo@gmail.com' ];
    for my $word ( @{$words} ) {
        $t->content_like( qr{\Q$word\E}, 'content check' );
    }

    # id -> 7 を指定して検索 (最初の 5件にはない)
    $t->get_ok('/admin/staff/search?id=7&name=')->status_is(200);
    $words = [ '絞り込み検索', 'hackerz.lab.karamatu@gmail.com' ];
    for my $word ( @{$words} ) {
        $t->content_like( qr{\Q$word\E}, 'content check' );
    }

    # ページャーの指定 id -> 7 (最初の 5件にはない)
    $t->get_ok('/admin/staff/search?page=2')->status_is(200);
    $words = [ '絞り込み検索', 'hackerz.lab.karamatu@gmail.com' ];
    for my $word ( @{$words} ) {
        $t->content_like( qr{\Q$word\E}, 'content check' );
    }

# 検索に該当しない場合のメッセージ  -> 「検索該当がありません」
    $t->get_ok('/admin/staff/search?id=999999&name=')->status_is(200);
    $words = [ '絞り込み検索', '「検索該当がありません」' ];
    for my $word ( @{$words} ) {
        $t->content_like( qr{\Q$word\E}, 'content check' );
    }

    # 名前の検索 address テーブル検索
    # 9,hackerz.lab.itimatu@gmail.com,itimatu,5,0,2016-01-08 12:24:12,2016-01-08 12:24:12
    # 9,9,松野 一松,まつの いちまつ,いちまつ,0,2016-01-08 12:24:12,2016-01-08 12:24:12
    my $chars = '松野 一松';
    $t->get_ok( '/admin/staff/search?id=&name=' . $chars )->status_is(200);
    $words = [ '絞り込み検索', 'hackerz.lab.itimatu@gmail.com' ];
    for my $word ( @{$words} ) {
        $t->content_like( qr{\Q$word\E}, 'content check' );
    }

    # 名前と ID の検索 address テーブル検索
    $t->get_ok( '/admin/staff/search?id=9&name=' . $chars )->status_is(200);
    $words = [ '絞り込み検索', 'hackerz.lab.itimatu@gmail.com' ];
    for my $word ( @{$words} ) {
        $t->content_like( qr{\Q$word\E}, 'content check' );
    }

    # 名前と ID の検索 address テーブル検索 ( ID が違うので失敗する)
    $t->get_ok( '/admin/staff/search?id=99&name=' . $chars )->status_is(200);
    $words = [ '絞り込み検索', '「検索該当がありません」' ];
    for my $word ( @{$words} ) {
        $t->content_like( qr{\Q$word\E}, 'content check' );
    }

    # ログアウトする
    t::Util::logout_admin($t);

    # ログアウトの確認
    $t->get_ok('/admin/staff/search')->status_is(302);
    $t->header_is( location => '/admin/login' );
};

# 新規登録画面表示
subtest 'creata' => sub {
    t::Util::login_admin($t);
    $t->get_ok('/admin/staff/create')->status_is(200);

    # 初期表示
    my $words = [ '新規登録フォーム' ];
    for my $word ( @{$words} ) {
        $t->content_like( qr{\Q$word\E}, 'content check' );
    }

    #  入力フォームの存在確認
    my $tags = [
        'input[name=id]',       'input[name=login_id]',
        'input[name=password]', 'input[name=name]',
        'input[name=rubi]',     'input[name=nickname]',
        'input[name=email]',
    ];
    for my $tag ( @{$tags} ) {
        $t->element_exists( $tag, "element check $tag" );
    }
    t::Util::logout_admin($t);
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
