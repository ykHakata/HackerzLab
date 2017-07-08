package HackerzLab::DB::Base;
use Mojo::Base -base;
use Teng;
use Teng::Schema::Loader;
Teng->load_plugin('Pager');

=encoding utf8

=head1 NAME

HackerzLab::DB::Base - データベースオブジェクト (共通)

=cut

has [qw{conf}];

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::DB::Base!!';
}

sub teng {
    my $self = shift;
    my $conf = $self->conf->{db};

    my $dsn_str = $conf->{dsn_str};
    my $user    = $conf->{user};
    my $pass    = $conf->{pass};
    my $option  = $conf->{option};
    my $dbh     = DBI->connect( $dsn_str, $user, $pass, $option );
    my $teng    = Teng::Schema::Loader->load(
        dbh       => $dbh,
        namespace => 'HackerzLab::DB::Teng',
    );
    return $teng;
}

1;

__END__
