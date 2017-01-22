package HackerzLab::Util;
use Mojo::Base -base;
use Time::Piece;
use Exporter 'import';
our @EXPORT_OK = qw{
    welcome_util
    now_datetime_to_sqlite
};

=encoding utf8

=head1 NAME

HackerzLab::Util - ユーティリティー

=cut

# 呼び出しテスト
sub welcome_util {
    return 'welcome HackerzLab::Util!!';
}

sub now_datetime_to_sqlite {
    my $t    = localtime;
    my $date = $t->date;
    my $time = $t->time;
    return "$date $time";
}

1;

__END__
