package HackerzLab::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;

  # admin/index.html
  $self->render(text => 'HackerzLab Admin Pages');
  return;
}

1;
