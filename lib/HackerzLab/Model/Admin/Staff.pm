package HackerzLab::Model::Admin::Staff;
use Mojo::Base 'HackerzLab::Model::Base';
use Mojo::Util qw{dumper};

=encoding utf8

=head1 NAME

HackerzLab::Model::Admin::Staff - コントローラーモデル (管理機能/管理者ユーザー管理)

=cut

has [
    qw{
        req_params
        page
        staff_rows
        staff_row
        pager
        query_staff_id
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
    $self->page( $self->req_params->{page} || 1 );
    return $self;
}

# 一覧画面初期表示用 staff 情報
sub search_staff_index {
    my $self = shift;
    my $teng = $self->app->db->teng;
    my ( $rows, $pager ) = $teng->search_with_pager(
        'staff' => +{ deleted => 0 },
        +{ page => $self->page, rows => 5 }
    );
    $self->staff_rows($rows);
    $self->pager($pager);
    return $self;
}

# 入力条件による検索
sub search_staff {
    my $self = shift;
    my $teng = $self->app->db->teng;

    # パラメータ無き場合
    return $self->search_staff_index
        if !$self->req_params->{id} && !$self->req_params->{name};

    # sql maker にしろ 生 sql にしろ、
    # 検索条件を組み替えるのは厄介
    # 条件追加ごとににメソッド差し込み
    # 最終的に検索する staff.id を取得する
    # name がある場合は address
    # テーブルから検索 id を作り込み

    # 検索用の id セット
    $self->query_staff_id( $self->req_params->{id} );

    # 名前検索が存在する場合
    if ( $self->req_params->{name} ) {
        return $self if !$self->with_query_address_name();
    }

    # 検索条件
    my $cond = +{};
    $cond->{id}      = $self->query_staff_id;
    $cond->{deleted} = 0;

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
    my $name = $self->req_params->{name};

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
    $self->search_staff;
    my $rows = $self->staff_rows;
    $self->staff_row( shift @{$rows} );
    return $self;
}

1;

__END__
