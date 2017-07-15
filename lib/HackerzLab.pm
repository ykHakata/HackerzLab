package HackerzLab;
use Mojo::Base 'Mojolicious';
use HackerzLab::Model;

=encoding utf8

=head1 NAME

HackerzLab - ハッカーズラボ (アプリケーション)

=cut

# This method will run once at server start
sub startup {
    my $self = shift;

    my $etc_dir     = $self->home->rel_dir('etc');
    my $mode        = $self->mode;
    my $moniker     = $self->moniker;
    my $conf_file   = qq{$etc_dir/$moniker.$mode.conf};
    my $common_file = qq{$etc_dir/$moniker.common.conf};

    # 設定ファイル (読み込む順番に注意)
    $self->plugin( Config => +{ file => $common_file } );
    $self->plugin( Config => +{ file => $conf_file } );

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    # コントローラーモデル
    $self->helper(
        model =>
            sub { HackerzLab::Model->new( +{ conf => shift->app->config } ); }
    );

    # コマンドをロードするための他の名前空間
    push @{ $self->commands->namespaces }, 'HackerzLab::Command';

    # ルーティング前に共通して実行
    $self->hook(
        before_dispatch => sub {
            my $c          = shift;
            my $url        = $c->req->url;
            $self->helper( login_staff => sub {undef} );

            # ログイン、ログアウトページは例外
            return if $url =~ m{^/admin/login};
            return if $url =~ m{^/admin/logout};

            # 認証保護されたページ
            if ( $url =~ m{^/admin} ) {

                # セッション情報からログイン者の情報を取得
                my $admin_auth = $self->model->admin->auth->req_params(
                    +{ login_id => $c->session('login_id') } );
                if ( $admin_auth->is_valid_session ) {
                    $self->helper(
                        login_staff => sub { $admin_auth->valid_staff_row } );
                    return;
                }

                # セッション無き場合ログインページへ
                $c->flash( flash_msg => 'ログインが必要です' );
                $c->redirect_to('/admin/login');
                return;
            }
        }
    );

    # Router
    my $r = $self->routes;

    # テスト表示用
    $r->get('/not_found')->to('info#not_found');
    $r->get('/exception')->to('info#exception');

    # 告知用サイト(暫定) http://hackerzlab.com/
    # $r->get('/')->to('info#index');
    # $r->get('/index')->to('info#index');
    $r->get('/')->to('info#menu');
    $r->get('/index')->to('info#menu');
    $r->get('/info')->to('info#menu');

    # 公開ファイルの目次
    $r->get('/viewer')->to('viewer#index');

    # トレーニングサイト http://hackerzlab.com/training/
    $r->get('/training/')->to('training#index');

    # 管理サイト http://hackerzlab.com/admin/
    $r->get('/admin')->to('admin#index');
    $r->get('/admin/')->to('admin#index');
    $r->get('/admin/menu')->to('admin#menu');
    $r->get('/admin/menu/')->to('admin#menu');

    # ログイン/ログアウト関連
    $r->get('/admin/login')->to('Admin::Auth#index');
    $r->post('/admin/login')->to('Admin::Auth#login');
    $r->post('/admin/logout')->to('Admin::Auth#logout');
    $r->get('/admin/logout')->to('Admin::Auth#logout');

    # 管理者管理管理
    $r->get('/admin/staff')->to('Admin::Staff#index');
    $r->get('/admin/staff/search')->to('Admin::Staff#search');
    $r->get('/admin/staff/create')->to('Admin::Staff#create');
    $r->get('/admin/staff/:id')->to('Admin::Staff#show');
    $r->get('/admin/staff/:id/edit')->to('Admin::Staff#edit');
    $r->post('/admin/staff')->to('Admin::Staff#store');
    $r->post('/admin/staff/:id/update')->to('Admin::Staff#update');
    $r->post('/admin/staff/:id/remove')->to('Admin::Staff#remove');
}

1;

__END__
