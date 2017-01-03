package HackerzLab::Controller::Example;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  # $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
  $self->render(text => 'Welcome to the HackerzLab');
  return;
}

1;
