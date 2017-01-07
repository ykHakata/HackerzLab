use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

# できるだけ Mojo でできることは Mojo で済ませたい
use Mojo::Util qw{dumper};

# ハッカーシステムの読み込み
my $t = Test::Mojo->new('HackerzLab');

# ルーティングテスト
subtest 'router' => sub {

    # 慣例的に index と入力する人も考えて
    $t->get_ok('/')->status_is(200);
    $t->get_ok('/index')->status_is(200);
};

# テンプレート描画
subtest 'template' => sub {

    # \Q \E は文字として認識してくださいという意味
    $t->get_ok('/')->status_is(200);
    $t->content_like( qr{\QWelcome to the HackerzLab\E}, );

    $t->get_ok('/index')->status_is(200);
    $t->content_like( qr{\QWelcome to the HackerzLab\E}, );
};

done_testing();

__END__
