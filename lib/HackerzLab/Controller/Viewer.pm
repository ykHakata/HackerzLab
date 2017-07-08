package HackerzLab::Controller::Viewer;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw{dumper};

=encoding utf8

=head1 NAME

HackerzLab::Controller::Viewer - 公開ファイルの目次

=cut

sub index {
    my $self = shift;

    my $model_viewer = $self->model->viewer;

    # 1: ['...','...', ...] フルパスの文字列
    $model_viewer->public_files( $self->app->home->list_files('public') );

    # 2: データ構造に
    $model_viewer->parse_public_files;

    $self->stash->{index_public_files} = $model_viewer->index_public_files;

    $self->render(
        template => 'viewer/index',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

1;

__END__
