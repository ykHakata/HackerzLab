package HackerzLab::Model::Admin::Staff;
use Mojo::Base 'HackerzLab::Model::Base';
use Mojo::Util qw{dumper};
use HackerzLab::Util qw{welcome_util now_datetime_to_sqlite};

=encoding utf8

=head1 NAME

HackerzLab::Model::Admin::Staff - コントローラーモデル (管理機能/管理者ユーザー管理)

=cut

has [qw{login_staff}];

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Admin::Staff!!';
}

# 新規登録書き込み実行
sub exec_staff_store {
    my $self = shift;

    my $teng   = $self->db->teng;
    my $master = $self->db->master;

    # 連続して実行できない場合は無効
    my $txn = $teng->txn_scope;

    # ログイン情報取得
    my $login_staff_row = $self->login_staff;

    # パラメーター整形
    my $params = +{
        staff_row => +{
            login_id  => $self->req_params_passed->{login_id},
            password  => $self->req_params_passed->{password},
            authority => $self->req_params_passed->{authority},
            deleted   => $master->label('NOT_DELETED')->deleted->constant,
            create_ts => now_datetime_to_sqlite(),
            modify_ts => now_datetime_to_sqlite(),
        },
        address_row => +{
            name      => $self->req_params_passed->{name},
            rubi      => $self->req_params_passed->{rubi},
            nickname  => $self->req_params_passed->{nickname},
            email     => $self->req_params_passed->{email},
            deleted   => $master->label('NOT_DELETED')->deleted->constant,
            create_ts => now_datetime_to_sqlite(),
            modify_ts => now_datetime_to_sqlite(),
        },
    };

    my $create_ids = $login_staff_row->insert_staff_with_address($params);

    $txn->commit;
    return;
}

# 編集登録書き込み実行
sub exec_staff_update {
    my $self = shift;

    my $teng   = $self->db->teng;
    my $master = $self->db->master;

    # 連続して実行できない場合は無効
    my $txn = $teng->txn_scope;

    # 更新情報取得
    my $row = $teng->single( 'address',
        +{ id => $self->req_params_passed->{address_id} } );

    # パラメーター整形
    my $params = +{
        name      => $self->req_params_passed->{name},
        rubi      => $self->req_params_passed->{rubi},
        nickname  => $self->req_params_passed->{nickname},
        email     => $self->req_params_passed->{email},
        modify_ts => now_datetime_to_sqlite(),
    };
    $row->update($params);
    $txn->commit;
    return;
}

# 削除実行
sub exec_staff_remove {
    my $self     = shift;
    my $teng     = $self->db->teng;
    my $staff_id = $self->req_params->{id};

    # 連続して実行できない場合は無効
    my $txn = $teng->txn_scope;

    # 削除情報取得
    my $staff_row = $teng->single( 'staff', +{ id => $staff_id } );

    # 削除フラグ
    $staff_row->soft_delete;

    $txn->commit;
    return;
}

# login_id 二重登録防止、存在確認
sub is_duplication_staff_id {
    my $self     = shift;
    my $login_id = $self->req_params->{login_id};
    my $NOT_DELETED
        = $self->db->master->label('NOT_DELETED')->deleted->constant;
    my $row = $self->db->teng->single( 'staff',
        +{ login_id => $login_id, deleted => $NOT_DELETED, } );
    return 1 if $row;
    return;
}

# index テンプレート用 stash 埋め込み
sub to_template_index {
    my $self   = shift;
    my $teng   = $self->db->teng;
    my $master = $self->db->master;
    my $page   = $self->req_params->{page} || 1;
    my $search_cond
        = +{ deleted => $master->label('NOT_DELETED')->deleted->constant, };
    my $search_attr = +{ page => $page, rows => 5, };
    my ( $rows, $pager )
        = $teng->search_with_pager( 'staff', $search_cond, $search_attr );
    return +{
        staffs => $rows,
        pager  => $pager,
    };
}

# search テンプレート用 stash 埋め込み
sub to_template_search {
    my $self   = shift;
    my $teng   = $self->db->teng;
    my $master = $self->db->master;
    my $page   = $self->req_params->{page} || 1;

    my $search_cond
        = +{ deleted => $master->label('NOT_DELETED')->deleted->constant, };
    my $search_attr = +{ page => $page, rows => 5, };

    my $query = +{
        staff_id => $self->req_params->{id},
        name     => $self->req_params->{name},
    };

    # パラメータ無き場合 index 時の値を出力
    return $self->to_template_index if !$query->{staff_id} && !$query->{name};

    # sql maker にしろ 生 sql にしろ、
    # 検索条件を組み替えるのは厄介
    # 条件追加ごとににメソッド差し込み
    # 最終的に検索する staff.id を取得する
    # name がある場合は address
    # テーブルから検索 id を作り込み

    # 名前検索が存在する場合
    my $search_ids = $query->{staff_id};
    if ( $query->{name} ) {

        # 検索条件整理
        my $name = $query->{name};

        # like 検索用の値を作成
        my $like = '%' . $name . '%';

        my @address
            = $teng->search( 'address', +{ name => +{ 'like' => $like }, } );

        # 該当の staff_id をまとめる
        my $ids = [ map { $_->staff_id } @address ];

        # id の指定がある場合は ids の中身を検索 AND 条件
        if ( $query->{staff_id} ) {
            my @staff_ids = grep { $_ eq $query->{staff_id} } @{$ids};

            # ここで id が 0 の場合は検索対象がない、終了
            return +{ staffs => [], pager => undef, } if !scalar @staff_ids;
            $search_ids = \@staff_ids;
        }
        $search_ids = $ids;
    }

    # 検索条件
    $search_cond = +{ %{$search_cond}, id => $search_ids };

    # 検索
    my ( $rows, $pager )
        = $teng->search_with_pager( 'staff', $search_cond, $search_attr );
    return +{
        staffs => $rows,
        pager  => $pager,
    };
}

# create テンプレート用 stash 埋め込み
sub to_template_create {
    my $self   = shift;
    my $master = $self->db->master;
    return +{ authorities => $master->authority->sort_to_hash, };
}

# edit テンプレート用 stash 埋め込み
sub to_template_edit {
    my $self     = shift;
    my $staff_id = $self->req_params->{id};
    return if !$staff_id;
    my $row = $self->db->teng->single( 'staff',
        +{ id => $staff_id, deleted => 0 } );
    return if !$row;
    my $params = $row->get_columns;
    my $staff_hash
        = +{ %{$params}, authority => $row->authority_master->get_name, };
    return +{ staff => $staff_hash, };
}

# edit テンプレート form 埋め込み用
sub to_template_edit_form {
    my $self = shift;

    my $staff_id = $self->req_params->{id};
    return if !$staff_id;
    my $staff_row = $self->db->teng->single( 'staff',
        +{ id => $staff_id, deleted => 0 } );
    return if !$staff_row;

    my $staff_hash   = $staff_row->get_columns;
    my $address_hash = $staff_row->fetch_address->get_columns;
    return +{
        id         => $staff_hash->{id},
        address_id => $address_hash->{id},
        name       => $address_hash->{name},
        rubi       => $address_hash->{rubi},
        nickname   => $address_hash->{nickname},
        email      => $address_hash->{email},
    };
}

# show テンプレート用 stash 埋め込み
sub to_template_show {
    my $self     = shift;
    my $staff_id = $self->req_params->{id};
    return if !$staff_id;

    my $staff_row = $self->db->teng->single( 'staff',
        +{ id => $staff_id, deleted => 0 } );
    return if !$staff_row;

    my $staff_hash   = $staff_row->get_columns;
    my $address_hash = $staff_row->fetch_address->get_columns;
    return +{
        staff   => $staff_hash,
        address => $address_hash,
    };
}

1;

__END__
