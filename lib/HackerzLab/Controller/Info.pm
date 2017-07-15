package HackerzLab::Controller::Info;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME

Info - 告知用サイト

=cut

sub index {
    my $self = shift;
    $self->reply->static('index.html');
    return;
}

sub menu {
    my $self = shift;
    $self->render(
        template => 'info/index',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

# 本番用の not found ページを描画
sub not_found {
    my $self     = shift;
    my $mode_org = $self->app->mode;
    $self->app->mode('production');
    $self->reply->not_found;
    $self->app->mode($mode_org);
    return;
}

# 本番用の exception ページを描画
sub exception {
    my $self     = shift;
    my $mode_org = $self->app->mode;
    $self->app->mode('production');
    $self->reply->exception;
    $self->app->mode($mode_org);
    return;
}

1;

__END__
