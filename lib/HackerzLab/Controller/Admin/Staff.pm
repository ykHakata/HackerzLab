package HackerzLab::Controller::Admin::Staff;
use Mojo::Base 'HackerzLab::Controller';
use Mojo::Util qw{dumper};

=encoding utf8

=head1 NAME

HackerzLab::Controller::Admin::Staff - コントローラー (管理機能/管理者ユーザー管理)

=cut

# 一覧画面 (検索入力画面含み)
sub index {
    my $self = shift;
    my $admin_staff
        = $self->model->admin->staff->create( $self->req->params->to_hash );
    $admin_staff->search_staff_index;
    $self->stash->{staffs} = $admin_staff->staff_rows;
    $self->stash->{pager}  = $admin_staff->pager;
    $self->render( template => 'admin/staff/index' );
    return;
}

# 検索実行
sub search {
    my $self = shift;
    my $admin_staff
        = $self->model->admin->staff->create( $self->req->params->to_hash );

    # 入力条件による検索
    $admin_staff->search_staff_search;

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
    my $self        = shift;
    my $admin_staff = $self->model->admin->staff->create();
    $self->stash->{authorities} = $admin_staff->authorities;
    $self->render( template => 'admin/staff/create' );
    return;
}

# 個別詳細画面
sub show {
    my $self        = shift;
    my $params      = +{ id => $self->stash->{id}, };
    my $admin_staff = $self->model->admin->staff->create($params);
    $self->stash->{staff} = $admin_staff->search_staff_show->staff_row;

    # 存在しないユーザー
    if ( !$self->stash->{staff} ) {
        $self->flash( flash_msg => '存在しないユーザー' );
        $self->redirect_to('/admin/staff');
        return;
    }
    $self->render( template => 'admin/staff/show' );
    return;
}

# 個別編集入力画面
sub edit {
    my $self        = shift;
    my $params      = +{ id => $self->stash->{id}, };
    my $admin_staff = $self->model->admin->staff->create($params);
    $admin_staff->search_staff_edit;
    $self->stash->{staff} = $admin_staff->staff_row;

    # 存在しないユーザー
    if ( !$self->stash->{staff} ) {
        $self->flash( flash_msg => '存在しないユーザー' );
        $self->redirect_to('/admin/staff');
        return;
    }

    # フィルイン
    $self->render_fillin('admin/staff/edit', $admin_staff->edit_form_params);
    return;
}

# 新規登録実行
sub store {
    my $self = shift;

    # 入力
    my $admin_staff
        = $self->model->admin->staff->create( $self->req->params->to_hash );
    $admin_staff->login_staff($self->app->login_staff);

    # バリデート
    $admin_staff->validator_customize('admin_staff_store');

    # 失敗、フィルイン、もう一度入力フォーム表示
    if ( $admin_staff->validation_has_error ) {

        # エラーメッセージ
        $self->stash->{authorities} = $admin_staff->authorities;
        $self->stash->{validation_msg} = $admin_staff->validation_msg;
        $self->render_fillin('admin/staff/create', $admin_staff->req_params);
        return;
    }

    # DB 書き込み
    $admin_staff->exec_staff_store;

    # 書き込み保存終了、管理画面一覧へリダイレクト終了
    $self->flash( flash_msg => '新規登録完了しました' );
    $self->redirect_to('/admin/staff');
    return;
}

# 個別編集実行
sub update {
    my $self = shift;

    # 入力
    my $admin_staff
        = $self->model->admin->staff->create( $self->req->params->to_hash );

    # バリデート
    $admin_staff->validator_customize('admin_staff_update');

    # 失敗、フィルイン、もう一度入力フォーム表示
    if ( $admin_staff->validation_has_error ) {

        # エラーメッセージ
        $self->stash->{validation_msg} = $admin_staff->validation_msg;
        $admin_staff->search_staff_update;
        $self->stash->{staff} = $admin_staff->staff_row;
        $self->render_fillin('admin/staff/edit', $admin_staff->req_params);
        return;
    }

    # DB 書き込み
    $admin_staff->exec_staff_update;

    # 書き込み保存終了、修正画面リダイレクト終了
    $self->flash( flash_msg => '編集登録完了しました' );
    $self->redirect_to( '/admin/staff/' . $admin_staff->show_id );
    return;
}

# 個別削除実行
sub remove {
    my $self        = shift;
    my $params      = +{ id => $self->stash->{id}, };
    my $admin_staff = $self->model->admin->staff->create($params);

    # 削除実行
    $admin_staff->exec_staff_remove;

    # 完了後リダイレクト終了
    $self->flash( flash_msg => '削除完了しました' );
    $self->redirect_to('/admin/staff');
    return;
}

1;

__END__
