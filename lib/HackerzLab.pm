package HackerzLab;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');
  $self->plugin( 'Config', { 'file' => 'config/config.pl' } );

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  
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
