use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

# ハッカーシステムテスト共通
use t::Util;
my $t = t::Util::init();

ok(1);

# staff コントローラーのテスト

done_testing();

__END__
