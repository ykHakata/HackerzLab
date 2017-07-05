use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

# できるだけ Mojo でできることは Mojo で済ませたい
use Mojo::Util qw{dumper};

# ハッカーシステムテスト共通
use t::Util;
my $t = t::Util::init();

# ルーティングテスト
subtest 'router' => sub {

    # 慣例的に index と入力する人も考えて
    $t->get_ok('/')->status_is(200);
    $t->get_ok('/index')->status_is(200);
    $t->get_ok('/info')->status_is(200);
};

# テンプレート描画
subtest 'template' => sub {

    $t->get_ok('/')->status_is(200);
    $t->text_is('h1', 'Welcome to the HackerzLab');

    $t->get_ok('/index')->status_is(200);
    $t->text_is('h1', 'Welcome to the HackerzLab');

    $t->get_ok('/info')->status_is(200);
    $t->text_is('h1', 'Welcome to the HackerzLab');
};

done_testing();

__END__
