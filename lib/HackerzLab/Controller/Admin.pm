package HackerzLab::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;

  $self->render(template => 'admin/menu');
  return;
}

sub menu {
  my $self = shift;

  $self->render(template => 'admin/menu');
  return;
}

1;
