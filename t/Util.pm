package t::Util;
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

sub init {

    # app 実行前に mode 切り替え conf が読まれなくなる
    $ENV{MOJO_MODE} = 'testing';
    my $t = Test::Mojo->new('HackerzLab');

    # testing 以外では実行不可
    die 'not testing mode' if $t->app->mode ne 'testing';
    return $t;
}

1;

__END__
