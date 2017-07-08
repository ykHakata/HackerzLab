package HackerzLab::Model;
use Mojo::Base 'HackerzLab::Model::Base';
use HackerzLab::Model::Admin;
use HackerzLab::Model::Viewer;

=encoding utf8

=head1 NAME

HackerzLab::Model - コントローラーモデル (呼び出し)

=cut

has admin => sub {
    HackerzLab::Model::Admin->new( +{ conf => shift->conf } );
};

has viewer => sub {
    HackerzLab::Model::Viewer->new( +{ conf => shift->conf } );
};

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model!!';
}

1;

__END__
