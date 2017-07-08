package HackerzLab::DB;
use Mojo::Base 'HackerzLab::DB::Base';
use HackerzLab::DB::Master;

=encoding utf8

=head1 NAME

HackerzLab::DB - データベースオブジェクト (呼び出し)

=cut

has master => sub { HackerzLab::DB::Master->new(); };

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::DB!!';
}

1;

__END__
