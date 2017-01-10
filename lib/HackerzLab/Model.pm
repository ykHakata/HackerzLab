package HackerzLab::Model;
use Mojo::Base 'HackerzLab::Model::Base';
use Mojo::Loader qw{find_modules load_class};

=encoding utf8

=head1 NAME

HackerzLab::Model - コントローラーモデル (呼び出し)

=cut

# パッケージ名以下のモジュールを再起せずに読み込み
for my $module ( find_modules __PACKAGE__ ) {
    my $e = load_class $module;
    warn qq{Loading "$module" failed: $e} and next if ref $e;
    my @names = split '::', $module;
    my $method = lc pop @names;
    has $method => sub {
        $module->new( +{ app => shift->app } );
    };
}

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model!!';
}

1;

__END__
