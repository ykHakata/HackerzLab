package HackerzLab::Controller::Admin::Auth;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;

  $self->render(text => 'Auth#index');
  return;
}

sub login {
  my $self = shift;

  $self->render(text => 'Auth#login');
  return;
}

sub logout {
  my $self = shift;

  $self->render(text => 'Auth#logout');
  return;
}

1;
