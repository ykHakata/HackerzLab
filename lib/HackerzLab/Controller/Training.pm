package HackerzLab::Controller::Training;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;

  # training/index.html
  $self->render(text => 'HackerzLab Training Site');
  return;
}

1;
