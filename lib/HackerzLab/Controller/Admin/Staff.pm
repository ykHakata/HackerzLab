package HackerzLab::Controller::Admin::Staff;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw{dumper};

=encoding utf8

=head1 NAME

HackerzLab::Controller::Admin::Staff - コントローラー (管理機能/管理者ユーザー管理)

=cut

# 一覧画面 (検索入力画面含み)
sub index {
    my $self        = shift;
    my $admin_staff = $self->model->admin->staff;
    $admin_staff->create( $self->req->params->to_hash );
    $admin_staff->get_index_staff();
    $self->stash->{staffs} = $admin_staff->staff_rows;
    $self->stash->{pager}  = $admin_staff->pager;
    $self->render( template => 'admin/staff/index' );
    return;
}

# 検索実行
sub search {
    my $self        = shift;
    my $admin_staff = $self->model->admin->staff;
    $admin_staff->create( $self->req->params->to_hash );

    # 入力条件による検索
    $admin_staff->search_staff;

    # 検索結果の値一式 (staff, ページ の情報)
    $self->stash->{staffs} = $admin_staff->staff_rows;
    $self->stash->{pager}  = $admin_staff->pager;

    # teng の row は該当なしの場合は undef だが pager は []
    if ( !@{ $self->stash->{staffs} } ) {
        $self->stash->{msg} = '「検索該当がありません」';
    }
    $self->render( template => 'admin/staff/index' );
    return;
}

# 新規登録画面表示
sub create {
    my $self = shift;
    $self->render( template => 'admin/staff/create' );
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
