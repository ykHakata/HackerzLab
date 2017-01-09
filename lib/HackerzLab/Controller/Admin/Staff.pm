package HackerzLab::Controller::Admin::Staff;
use Mojo::Base 'Mojolicious::Controller';

=encoding utf8

=head1 NAME

HackerzLab::Controller::Admin::Staff - 管理者管理機能

=cut

# 一覧画面 (検索入力画面含み)
sub index {
    my $self = shift;
    $self->render( text => 'index' );
    return;
}

# 検索実行
sub search {
    my $self = shift;
    $self->render( text => 'search' );
    return;
}

# 新規登録画面表示
sub create {
    my $self = shift;
    $self->render( text => 'create' );
    return;
}

# 個別詳細画面
sub show {
    my $self = shift;
    $self->render( text => 'show' );
    return;
}

# 個別編集入力画面
sub edit {
    my $self = shift;
    $self->render( text => 'edit' );
    return;
}

# 新規登録実行
sub store {
    my $self = shift;
    $self->render( text => 'store' );
    return;
}

# 個別編集実行
sub update {
    my $self = shift;
    $self->render( text => 'update' );
    return;
}

# 個別削除実行
sub remove {
    my $self = shift;
    $self->render( text => 'remove' );
    return;
}

1;

__END__
