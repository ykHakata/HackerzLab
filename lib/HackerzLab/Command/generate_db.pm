package HackerzLab::Command::generate_db;
use Mojo::Base 'Mojolicious::Command';

has description => '';
has usage => <<"END_USAGE";
END_USAGE

sub run {
    my $self = shift;
    return;
}

1;

__END__
