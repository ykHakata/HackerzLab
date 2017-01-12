package t::Util;
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

=encoding utf8

=head1 NAME

t::Util - テストコードユーティリティ

=cut

# データ初期化など
sub init {

    # app 実行前に mode 切り替え conf が読まれなくなる
    $ENV{MOJO_MODE} = 'testing';
    my $t = Test::Mojo->new('HackerzLab');

    # testing 以外では実行不可
    die 'not testing mode' if $t->app->mode ne 'testing';

    # テスト用DB初期化
    $t->app->commands->run('generate_db');
    return $t;
}

# 管理者機能にログインする
sub login_admin {
    my $t = shift;

    # テスト用の staff データの存在確認
    my $row = $t->app->db->teng->single( 'staff', +{ id => 1 } );
    ok($row);

    my $params = +{
        email    => $row->login_id,
        password => $row->password,
    };

    # 302リダイレクトレスポンスの許可
    $t->ua->max_redirects(1);
    $t->post_ok( '/admin/login' => form => $params )->status_is(200);
    $t->content_like(qr{\Qログインしました\E});
    $t->ua->max_redirects(0);
    return;
}

# 管理者機能をログアウトする
sub logout_admin {
    my $t = shift;

    # ログアウトの実行
    $t->post_ok('/admin/logout')->status_is(302);

    # リダイレクト先の確認
    my $location_url = '/admin/logout';
    $t->header_is( location => $location_url );

    # リダイレクト先でアクセス後、セッション確認
    $t->get_ok($location_url)->status_is(200);
    my $session_id = $t->app->build_controller( $t->tx )->session('login_id');
    is( $session_id, undef, 'session_id' );
    return;
}

1;

__END__
