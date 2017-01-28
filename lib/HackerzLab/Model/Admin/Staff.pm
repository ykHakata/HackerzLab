package HackerzLab::Model::Admin::Staff;
use Mojo::Base 'HackerzLab::Model::Base';
use Mojo::Util qw{dumper};
use HackerzLab::Util qw{welcome_util now_datetime_to_sqlite};

=encoding utf8

=head1 NAME

HackerzLab::Model::Admin::Staff - コントローラーモデル (管理機能/管理者ユーザー管理)

=cut

has [
    qw{
        page
        staff_id
        name
        staff_rows
        staff_row
        pager
        query_staff_id
        query_name
        show_id
        edit_form_params
        }
];

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Admin::Staff!!';
}

# オブジェクト作成
sub create {
    my $self   = shift;
    my $params = shift;
    $self->req_params($params);

    $self->staff_id( $params->{id} );
    $self->name( $params->{name} );
    $self->page( $params->{page} || 1 );
    return $self;
}

# 一覧画面初期表示用 staff 情報
sub search_staff_index {
    my $self   = shift;
    my $teng   = $self->app->db->teng;
    my $master = $self->app->db->master;
    my ( $rows, $pager ) = $teng->search_with_pager(
        'staff',
        +{ deleted => $master->label('NOT_DELETED')->deleted->constant },
        +{ page    => $self->page, rows => 5 },
    );
    $self->staff_rows($rows);
    $self->pager($pager);
    return $self;
}

sub search_staff_search {
    my $self = shift;

    # 検索条件
    $self->query_staff_id( $self->staff_id );
    $self->query_name( $self->name );
    $self->search_staff;
    return $self;
}

# 入力条件による検索
sub search_staff {
    my $self   = shift;
    my $teng   = $self->app->db->teng;
    my $master = $self->app->db->master;

    # パラメータ無き場合
    return $self->search_staff_index
        if !$self->query_staff_id && !$self->query_name;

    # sql maker にしろ 生 sql にしろ、
    # 検索条件を組み替えるのは厄介
    # 条件追加ごとににメソッド差し込み
    # 最終的に検索する staff.id を取得する
    # name がある場合は address
    # テーブルから検索 id を作り込み

    # 名前検索が存在する場合
    if ( $self->query_name ) {
        return $self if !$self->with_query_address_name();
    }

    # 検索条件
    my $cond = +{};
    $cond->{id}      = $self->query_staff_id;
    $cond->{deleted} = $master->label('NOT_DELETED')->deleted->constant;

    # 検索
    my ( $rows, $pager )
        = $teng->search_with_pager( 'staff', $cond,
        +{ page => $self->page, rows => 5 } );
    $self->staff_rows($rows);
    $self->pager($pager);
    return $self;
}

# 名前による条件検索
sub with_query_address_name {
    my $self = shift;
    my $teng = $self->app->db->teng;

    # 検索条件整理
    my $name = $self->query_name;

    # like 検索用の値を作成
    my $like = '%' . $name . '%';

    my @address
        = $teng->search( 'address', +{ name => +{ 'like' => $like }, } );

    # 該当の staff_id をまとめる
    my $ids = [ map { $_->staff_id } @address ];

    # id の指定がある場合は ids の中身を検索 AND 条件
    if ( $self->query_staff_id ) {
        my @staff_ids = grep { $_ eq $self->query_staff_id } @{$ids};

        # ここで id が 0 の場合は検索対象がない、終了
        if ( !scalar @staff_ids ) {
            $self->staff_rows( [] );
            $self->pager(undef);
            return;
        }
        $self->query_staff_id( \@staff_ids );
        return 1;
    }
    $self->query_staff_id($ids);
    return 1;
}

# 詳細画面向け検索
sub search_staff_show {
    my $self = shift;

    # 検索条件
    $self->query_staff_id( $self->staff_id );
    $self->query_name(undef);
    $self->search_staff;
    $self->staff_row( shift @{ $self->staff_rows } );
    return $self;
}

# 編集画面向け検索一式
sub search_staff_edit {
    my $self = shift;

    # 検索条件
    $self->query_staff_id( $self->staff_id );
    $self->query_name(undef);
    $self->search_staff;
    $self->staff_row( shift @{ $self->staff_rows } );

    my $staff_hash   = $self->staff_row->get_columns;
    my $address_hash = $self->staff_row->fetch_address->get_columns;
    my $params       = +{
        id         => $staff_hash->{id},
        address_id => $address_hash->{id},
        name       => $address_hash->{name},
        rubi       => $address_hash->{rubi},
        nickname   => $address_hash->{nickname},
        email      => $address_hash->{email},
    };
    $self->edit_form_params($params);
    return $self;
}

# 編集実行時の検索一式
sub search_staff_update {
    my $self = shift;

    # 検索条件
    $self->query_staff_id( $self->staff_id );
    $self->query_name(undef);
    $self->search_staff;
    $self->staff_row( shift @{ $self->staff_rows } );
    return $self;
}

# 新規登録書き込み実行
sub exec_staff_store {
    my $self = shift;

    my $teng   = $self->app->db->teng;
    my $master = $self->app->db->master;

    # 連続して実行できない場合は無効
    my $txn = $teng->txn_scope;

    # ログイン情報取得
    my $login_staff_row = $self->app->login_staff;

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

    my $teng   = $self->app->db->teng;
    my $master = $self->app->db->master;

    # 連続して実行できない場合は無効
    my $txn = $teng->txn_scope;

    # 更新情報取得
    my $row = $teng->single( 'address',
        +{ id => $self->req_params->{address_id} } );

    # パラメーター整形
    my $params = +{
        name      => $self->req_params->{name},
        rubi      => $self->req_params->{rubi},
        nickname  => $self->req_params->{nickname},
        email     => $self->req_params->{email},
        modify_ts => now_datetime_to_sqlite(),
    };
    $row->update($params);
    $txn->commit;
    $self->show_id( $self->staff_id );
    return;
}

1;

__END__
