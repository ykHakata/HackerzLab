package HackerzLab::Controller::Admin::Auth;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;

  $self->render(template => 'admin/login');
  return;
}

sub login {
  my $self = shift;

  $self->render(text => 'Auth#login');
  return;
}

sub logout {
  my $self = shift;

  $self->render(template => 'admin/logout');
  return;
}

1;
