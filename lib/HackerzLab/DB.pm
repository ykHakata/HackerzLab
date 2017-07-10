package HackerzLab::DB;
use Mojo::Base 'HackerzLab::DB::Base';
use HackerzLab::DB::Master;
use HackerzLab::DB::Message;

=encoding utf8

=head1 NAME

HackerzLab::DB - データベースオブジェクト (呼び出し)

=cut

has master  => sub { HackerzLab::DB::Master->new(); };
has message => sub { HackerzLab::DB::Message->new(); };

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::DB!!';
}

1;

__END__
