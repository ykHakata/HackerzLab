package HackerzLab::Model::Viewer;
use Mojo::Base 'HackerzLab::Model::Base';
use File::Basename qw{fileparse};

=encoding utf8

=head1 NAME

HackerzLab::Model::Viewer - コントローラーモデル (公開ファイルの目次)

=cut

has [qw{public_files index_public_files}];

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Viewer!!';
}

# 2: データ構造に
# [   +{  dir_path => $dir_path,
#         file     => $file,
#         url_link => $url_link,
#     },
#     +{ ... },
# ];
sub parse_public_files {
    my $self = shift;

    my $index_public_files;
    for my $public_file ( @{ $self->public_files } ) {
        my ( $file, $dir_path ) = fileparse($public_file);
        my $url_link = "/$public_file";
        my $row      = +{
            dir_path => $dir_path,
            file     => $file,
            url_link => $url_link,
        };
        push @{$index_public_files}, $row;
    }
    $self->index_public_files($index_public_files);
    return;
}

1;

__END__
