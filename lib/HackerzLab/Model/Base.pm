package HackerzLab::Model::Base;
use Mojo::Base -base;

=encoding utf8

=head1 NAME

HackerzLab::Model::Base - コントローラーモデル (共通)

=cut

has [qw{app}];

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Base!!';
}

1;

__END__
