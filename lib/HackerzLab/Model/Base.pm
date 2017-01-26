package HackerzLab::Model::Base;
use Mojo::Base -base;
use Mojo::Util qw{dumper};
=encoding utf8

=head1 NAME

HackerzLab::Model::Base - コントローラーモデル (共通)

=cut

has [
    qw{
        app
        req_params
        req_params_passed
        validation_has_error
        validation_is_valid
        validation_msg
        validation_set_error_msg
        validation_login_staff
        }
];

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Base!!';
}

# 共通バリデーションロジック
sub validator_customize {
    my $self       = shift;
    my $class_name = shift;

    die 'not validation calss name' if !$class_name;

    my $method     = 'validation_' . $class_name;
    my $validation = $self->$method;
    my $error      = $self->validation_set_error_msg;

    $self->validation_has_error( $validation->has_error );
    $self->validation_is_valid( $validation->is_valid );
    $self->validation_msg(undef);

    if ( $self->validation_has_error ) {

        my $msg;
        my $names = $validation->failed;
        for my $name ( @{$names} ) {

            # エラーメッセージセット
            my $check
                = $validation->error( $name, $error->{$name} )->error($name);
            push @{$msg}, shift @{$check};
        }
        $self->validation_msg($msg);

        # 失敗時はここで終了
        $self->req_params_passed(undef);
        return $self;
    }

    # 成功の値をセット
    $self->req_params_passed( $validation->output );
    return $self;
}

# DB 存在確認
sub validation_exists_login_id {
    my $self = shift;

    my $validator = $self->app->validator;

    $validator->add_check(
        exists_login_id => sub {
            my ( $validation, $name, $login_id, ) = @_;
            my $NOT_DELETED
                = $self->app->db->master->label('NOT_DELETED')
                ->deleted->constant;
            my $row = $self->app->db->teng->single( 'staff',
                +{ login_id => $self->login_id, deleted => $NOT_DELETED, } );
            $self->validation_login_staff($row);
            return 1 if !$row;
            return;
        }
    );

    my $validation = $validator->validation;
    $validation->input( $self->req_params );
    my $value = $validation->param('login_id');
    $validation->required('login_id')->exists_login_id($value);

    $self->validation_set_error_msg(
        +{ login_id => ['ログインID(email)が存在しません'], } );
    return $validation;
}

# password 照合
sub validation_check_password {
    my $self = shift;

    my $validator = $self->app->validator;

    $validator->add_check(
        check_password => sub {

            # TODO DB のパスワードは暗号化される予定
            # $row->password を複合化して照合
            # return if $password eq $self->decrypt($row->password);
            my ( $validation, $name, $password, ) = @_;
            my $row = $self->validation_login_staff;
            return 1 if !$row;
            return   if $password eq $row->password;
            return 1;
        }
    );

    my $validation = $validator->validation;
    $validation->input( $self->req_params );
    my $value = $validation->param('password');
    $validation->required('password')->check_password($value);
    $self->validation_set_error_msg(
        +{ password => ['ログインパスワードがちがいます'] } );
    return $validation;
}

# 新規登録パラメーターバリデート
sub validation_admin_auth_login {
    my $self = shift;

    my $validation = $self->app->validator->validation;
    $validation->input( $self->req_params );

    $validation->required('login_id')->size( 1, 100 );
    $validation->required('password')->size( 1, 100 );

    $self->validation_set_error_msg(
        +{  login_id => ['ログインID(email)'],
            password => ['ログインパスワード'],
        }
    );
    return $validation;
}

# 新規登録パラメーターバリデート
sub validation_admin_staff_store {
    my $self = shift;

    my $validation = $self->app->validator->validation;
    $validation->input( $self->req_params );

    $validation->required('login_id')->size( 1, 100 );
    $validation->required('password')->size( 1, 100 );
    $validation->required('authority');
    $validation->required('name')->size( 1, 100 );
    $validation->required('rubi')->size( 1, 100 );
    $validation->required('nickname')->size( 1, 100 );
    $validation->required('email')->size( 1, 100 );

    $self->validation_set_error_msg(
        +{  login_id  => ['ログインID'],
            password  => ['ログインパスワード'],
            authority => ['管理者権限'],
            name      => ['名前'],
            rubi      => ['ふりがな'],
            nickname  => ['表示用ニックネーム'],
            email     => ['連絡用メールアドレス'],
        }
    );
    return $validation;
}

1;

__END__
