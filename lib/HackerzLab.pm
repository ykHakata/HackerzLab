package HackerzLab;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    my $etc_dir     = $self->home->rel_dir('etc');
    my $mode        = $self->mode;
    my $moniker     = $self->moniker;
    my $conf_file   = qq{$etc_dir/$moniker.$mode.conf};
    my $common_file = qq{$etc_dir/$moniker.common.conf};

    # 設定ファイル
    $self->plugin( Config => +{ file => $conf_file } );
    $self->plugin( Config => +{ file => $common_file } );

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');
    $self->plugin( 'Config', { 'file' => 'config/config.pl' } );

    # コマンドをロードするための他の名前空間
    push @{ $self->commands->namespaces }, 'HackerzLab::Command';

    # Router
    my $r = $self->routes;

    # 告知用サイト(暫定) http://hackerzlab.com/
    $r->get('/')->to('info#index');
    $r->get('/index')->to('info#index');

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
}

1;

__END__
