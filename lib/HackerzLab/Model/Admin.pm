package HackerzLab::Model::Admin;
use Mojo::Base 'HackerzLab::Model::Base';
use HackerzLab::Model::Admin::Auth;
use HackerzLab::Model::Admin::Staff;

=encoding utf8

=head1 NAME

HackerzLab::Model::Admin - コントローラーモデル (管理機能/呼び出し)

=cut

has auth => sub {
    HackerzLab::Model::Admin::Auth->new( +{ conf => shift->conf } );
};

has staff => sub {
    HackerzLab::Model::Admin::Staff->new( +{ conf => shift->conf } );
};

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Admin!!';
}

1;

__END__
