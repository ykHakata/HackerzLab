package HackerzLab::DB;
use Mojo::Base 'HackerzLab::DB::Base';

=encoding utf8

=head1 NAME

HackerzLab::DB - データベースオブジェクト (呼び出し)

=cut

# DB 内は拡張する予定がないので Loader やめる
# 継承しているので base メソッドも不要かもしれない
has base => sub {
    HackerzLab::DB::Base->new( +{ app => shift->app } );
};

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::DB!!';
}

1;

__END__
