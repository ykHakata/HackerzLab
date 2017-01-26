package HackerzLab::Model::Admin::Auth;
use Mojo::Base 'HackerzLab::Model::Base';
use Mojo::Util qw{dumper};

=encoding utf8

=head1 NAME

HackerzLab::Model::Admin::Auth - コントローラーモデル (管理機能/管理者認証)

=cut

has [
    qw{
        login_id
        login_row
        password
        decrypt_password
        encrypt_session_id
        }
];

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Admin::Auth!!';
}

# オブジェクト作成
sub create {
    my $self   = shift;
    my $params = shift;
    $self->req_params($params);

    # アクセスメソッドへ
    $self->login_id( $params->{login_id} );
    $self->password( $params->{password} );
    $self->login_row(undef);
    return $self;
}

# DB 存在確認
sub exists_login_id {
    my $self = shift;
    return if !$self->login_id;
    my $NOT_DELETED
        = $self->app->db->master->label('NOT_DELETED')->deleted->constant;
    my $row = $self->app->db->teng->single( 'staff',
        +{ login_id => $self->login_id, deleted => $NOT_DELETED, } );
    return if !$row;
    $self->login_row($row);
    return $row;
}

# password 確認
sub check_password {
    my $self = shift;
    return if !$self->password;

    # TODO: password を復号化して照合 (後ほど実装)
    # decrypt (復号化) || encrypt (暗号化)
    return if !$self->decrypt_exec_password();

    # DB 保存の password は暗号化 (decrypt) される予定
    return 1 if $self->password eq $self->decrypt_password;
    return;
}

# DB の password 復号化
sub decrypt_exec_password {
    my $self = shift;

    # TODO: 後ほど暗号、復号のロジックを
    $self->decrypt_password( $self->login_row->password );

    # 現状は常に成功
    return 1;
    return;
}

# session 用 id の暗号化
sub encrypt_exec_session_id {
    my $self = shift;

    # TODO: 後ほど暗号、復号のロジックを
    $self->encrypt_session_id( $self->login_row->login_id );

    # 現状は常に成功
    return 1;
    return;
}

# 合格の値を再配置
sub setup_req_params {
    my $self = shift;
    $self->login_row( $self->validation_login_staff );
    $self->validation_login_staff(undef);
    return $self;
}

# ログインしている staff 情報取得
sub get_login_staff {
    my $self = shift;
    return if !$self->login_id;
    my $NOT_DELETED
        = $self->app->db->master->label('NOT_DELETED')->deleted->constant;
    my $row = $self->app->db->teng->single( 'staff',
        +{ login_id => $self->login_id, deleted => $NOT_DELETED, } );
    return if !$row;
    return $row;
}

1;

__END__
