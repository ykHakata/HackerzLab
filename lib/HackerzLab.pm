package HackerzLab;
use Mojo::Base 'Mojolicious';
use HackerzLab::DB;
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
    $self->plugin( 'Config', { 'file' => 'config/config.pl' } );

    # データーベース
    $self->helper(
        db => sub {
            state $db = HackerzLab::DB->new( +{ app => $self->app } );
        }
    );

    # コントローラーモデル
    $self->helper(
        model => sub {
            state $model = HackerzLab::Model->new( +{ app => $self->app } );
        }
    );

    # コマンドをロードするための他の名前空間
    push @{ $self->commands->namespaces }, 'HackerzLab::Command';

    # Router
    my $r = $self->routes;

    # 告知用サイト(暫定) http://hackerzlab.com/
    $r->get('/')->to('info#index');
    $r->get('/index')->to('info#index');

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
