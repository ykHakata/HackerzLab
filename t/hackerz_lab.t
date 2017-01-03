use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

# データ構造をダンプする
use Data::Dumper;

# ハッカーシステムの読み込み
my $t = Test::Mojo->new('HackerzLab');

# ルーティングのテスト
subtest 'router' => sub {
    # http://hackerzlab.com/ (告知サイト)
    $t->get_ok('/index.html')->status_is(200)->content_like(qr/Welcome to the HackerzLab/i);
    $t->get_ok('/')->status_is(200)->content_like(qr/Welcome to the HackerzLab/i);

    # データの中身をダンプする
    warn 'menu-------: ' , Dumper($t->tx->res->body);

    # http://hackerzlab.com/training/ (トレーニングサイト)
    $t->get_ok('/training/')->status_is(200)->content_like(qr/HackerzLab Training Site/i);

    # http://hackerzlab.com/admin/ (管理画面)
    $t->get_ok('/admin/')->status_is(200)->content_like(qr/HackerzLab Admin Pages/i);
};

# フォルダ構造(コントローラーの中身)
# lib/HackerzLab/
# lib/HackerzLab/HackerzLab.pm
# lib/HackerzLab/Controller/
# lib/HackerzLab/Controller/Admin.pm
# lib/HackerzLab/Controller/Admin
# lib/HackerzLab/Controller/Example.pm
# lib/HackerzLab/Controller/Training.pm
# lib/HackerzLab/Controller/Training

# コントローラーのファイルの存在確認
subtest 'controller files exist' => sub {
    my $home = $t->app->home();
    my $files = $home->list_files('lib/HackerzLab/Controller/');
    my $test_files = [qw{Admin.pm Training.pm}];
    for my $file ( @{$test_files} ){
        my $text = grep { $_ eq $file } @{$files};
        is( $text, 1, "file name test $file" );
    }
};

done_testing();
