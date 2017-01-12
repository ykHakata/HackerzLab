package HackerzLab::Controller::Info;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME

Info - 告知用サイト

=cut

sub index {
    my $self = shift;
    $self->reply->static('index.html');
    return;
}

sub menu {
    my $self = shift;
    $self->render(
        template => 'info/index',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

1;

__END__
