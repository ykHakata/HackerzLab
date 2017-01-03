use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

# データ構造をダンプする
use Data::Dumper;

# ハッカーシステムの読み込み
my $t = Test::Mojo->new('HackerzLab');

# http://hackerzlab.com/ (告知サイト)
$t->get_ok('/index.html')->status_is(200)->content_like(qr/Welcome to the HackerzLab/i);
$t->get_ok('/')->status_is(200)->content_like(qr/Welcome to the HackerzLab/i);

# データの中身をダンプする
warn 'menu-------: ' , Dumper($t->tx->res->body);

done_testing();
