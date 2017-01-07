use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

# ハッカーシステムの読み込み
my $t = Test::Mojo->new('HackerzLab');

# 呼び出し確認
subtest 'test run' => sub {
    my $command_run = 0;
    eval { $t->app->commands->run('generate_db'); };
    if ($@) {
        ok( $command_run, "$@" );
    }
    else {
        $command_run = 1;
        ok( $command_run, 'command_run' );
    }
};

# データベース作成 (テスト用)
# 他のDBを書き換えると良く無いのでテストDBのみ確認
subtest 'create db testing' => sub {
    my $mode     = 'testing';
    my $mode_org = $t->app->mode;
    my $conf     = $t->app->config;

    # mode 変更
    _mode_switch($mode);

    # データベースファイル存在確認 (無いこと)
    # ある場合は一旦削除
    my $database_dir  = $conf->{database_dir};
    my $database_name = $conf->{database_name};
    my $file          = qq{$database_dir/$database_name.$mode.db};

    if ( -f $file ) {
        unlink $file;
    }

    is( -f $file, undef, 'file check' );

    # コマンド実行
    $t->app->commands->run('generate_db');

    # データベースファイル存在確認 (存在する)
    is( -f $file, 1, 'file check' );

    # データベースファイル削除 (次のテストのため)
    if ( -f $file ) {
        unlink $file;
    }

    # mode もどす
    _mode_switch($mode_org);
};

# mode 変更
sub _mode_switch {
    my $mode = shift;
    $t->app->mode($mode);
    my $mode_check = $t->app->mode;
    is( $mode_check, $mode, "$mode mode test" );
    return;
}

done_testing();

__END__
