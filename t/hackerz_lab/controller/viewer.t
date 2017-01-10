use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

# ハッカーシステムテスト共通
use t::Util;
my $t = t::Util::init();

# ルーティングテスト
subtest 'router' => sub {
    $t->get_ok('/viewer')->status_is(200);
};

done_testing();

__END__
