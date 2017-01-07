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

done_testing();

__END__
