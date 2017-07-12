package HackerzLab::Model::Admin::Auth;
use Mojo::Base 'HackerzLab::Model::Base';
use Mojo::Util qw{dumper};

=encoding utf8

=head1 NAME

HackerzLab::Model::Admin::Auth - コントローラーモデル (管理機能/管理者認証)

=cut

has [qw{valid_staff_row}];

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Admin::Auth!!';
}

# TODO: decrypt (復号化) || encrypt (暗号化) の仕組みを実装
# TODO: DB の password 暗号化 復号化
# TODO: session 用 id の暗号化  復号化

# 削除されていない staff row
sub _get_enabled_staff_row {
    my $self     = shift;
    my $login_id = shift;
    my $NOT_DELETED
        = $self->db->master->label('NOT_DELETED')->deleted->constant;
    my $row = $self->db->teng->single( 'staff',
        +{ login_id => $login_id, deleted => $NOT_DELETED, } );
    return $row;
}

# セッションの妥当性
sub is_valid_session {
    my $self     = shift;
    my $login_id = $self->req_params->{login_id};
    $self->valid_staff_row(undef);
    my $row = $self->_get_enabled_staff_row($login_id);
    $self->valid_staff_row($row);
    return 1 if $row;
    return;
}

# DB 存在確認
sub is_invalid_login_id {
    my $self     = shift;
    my $login_id = $self->req_params->{login_id};
    my $row      = $self->_get_enabled_staff_row($login_id);
    $self->validation_login_staff($row);
    return 1 if !$row;
    return;
}

# password 照合
sub is_invalid_password {
    my $self     = shift;
    my $password = $self->req_params->{password};

    # TODO DB のパスワードは暗号化される予定
    # $row->password を複合化して照合
    # return if $password eq $self->decrypt($row->password);
    my $row = $self->validation_login_staff;
    return 1 if !$row;
    return   if $password eq $row->password;
    return 1;
}

# ログイン成功後に埋め込むセッション
sub embed_session_id {
    my $self     = shift;
    my $login_id = $self->req_params->{login_id};
    return $login_id;
}

1;

__END__
