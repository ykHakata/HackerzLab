package HackerzLab::Model::Base;
use Mojo::Base -base;
use Mojo::Util qw{dumper trim};
use HackerzLab::DB;
use Mojolicious::Validator;

=encoding utf8

=head1 NAME

HackerzLab::Model::Base - コントローラーモデル (共通)

=cut

has [
    qw{
        conf
        req_params
        req_params_passed
        validation_has_error
        validation_is_valid
        validation_msg
        validation_set_error_msg
        validation_login_staff
        }
];

has db => sub {
    HackerzLab::DB->new( +{ conf => shift->conf } );
};

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Base!!';
}

# 共通トリムチェック
my $trim_check = sub {
    my ( $validation, $name, $value, ) = @_;
    my $original = $value;
    my $trimmed  = trim($value);
    return if length $original eq length $trimmed;
    return 1;
};

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

# 新規登録パラメーターバリデート
sub validation_admin_auth_login {
    my $self       = shift;
    my $validator  = Mojolicious::Validator->new;
    my $validation = $validator->validation;

    $validation->input( $self->req_params );

    $validation->required('login_id')->size( 1, 100 );
    $validation->required('password')->size( 1, 100 );

    $self->validation_set_error_msg(
        +{  login_id => ['ログインID(email)'],
            password => ['ログインパスワード'],
        }
    );
    return $validation if $validation->has_error;

    # DB 存在確認
    $validator->add_check(
        exists_login_id => sub {
            my ( $validation, $name, $login_id, ) = @_;
            my $NOT_DELETED
                = $self->db->master->label('NOT_DELETED')
                ->deleted->constant;
            my $row = $self->db->teng->single( 'staff',
                +{ login_id => $login_id, deleted => $NOT_DELETED, } );
            $self->validation_login_staff($row);
            return 1 if !$row;
            return;
        }
    );
    $validation->required('login_id')->exists_login_id;
    $self->validation_set_error_msg(
        +{ login_id => ['ログインID(email)が存在しません'], } );
    return $validation if $validation->has_error;

    # password 照合
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
    $validation->required('password')->check_password;
    $self->validation_set_error_msg(
        +{ password => ['ログインパスワードがちがいます'] } );
    return $validation;
}

# 新規登録パラメーターバリデート
sub validation_admin_staff_store {
    my $self       = shift;
    my $validator  = Mojolicious::Validator->new;

    # 前後の空白禁止
    $validator->add_check( trim_check => $trim_check );

    my $validation = $validator->validation;

    $validation->input( $self->req_params );

    $validation->required('login_id')->size( 1, 100 )->trim_check;
    $validation->required('password')->size( 1, 100 )->trim_check;
    $validation->required('authority')->trim_check;
    $validation->required('name')->size( 1, 100 )->trim_check;
    $validation->required('rubi')->size( 1, 100 )->trim_check;
    $validation->required('nickname')->size( 1, 100 )->trim_check;
    $validation->required('email')->size( 1, 100 )->trim_check;

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
    return $validation if $validation->has_error;

    # login_id 二重登録防止
    $validator->add_check(
        not_exists_login_id => sub {
            my ( $validation, $name, $login_id, ) = @_;
            my $NOT_DELETED
                = $self->db->master->label('NOT_DELETED')
                ->deleted->constant;
            my $row = $self->db->teng->single( 'staff',
                +{ login_id => $login_id, deleted => $NOT_DELETED, } );
            return 1 if $row;
            return;
        }
    );
    $validation->required('login_id')->not_exists_login_id;
    $self->validation_set_error_msg(
        +{  login_id => [
                '入力されたログインID(email)はすでに登録済みです'
            ],
        }
    );
    return $validation;
}

# 更新登録パラメーターバリデート
sub validation_admin_staff_update {
    my $self      = shift;
    my $validator = Mojolicious::Validator->new;

    # 前後の空白禁止
    $validator->add_check( trim_check => $trim_check );

    my $validation = $validator->validation;
    $validation->input( $self->req_params );

    $validation->required('id')->trim_check;
    $validation->required('address_id')->trim_check;
    $validation->required('name')->size( 1, 100 )->trim_check;
    $validation->required('rubi')->size( 1, 100 )->trim_check;
    $validation->required('nickname')->size( 1, 100 )->trim_check;
    $validation->required('email')->size( 1, 100 )->trim_check;

    $self->validation_set_error_msg(
        +{  id         => ['管理ユーザーID'],
            address_id => ['住所ID'],
            name       => ['名前'],
            rubi       => ['ふりがな'],
            nickname   => ['表示用ニックネーム'],
            email      => ['連絡用メールアドレス'],
        }
    );
    return $validation;
}

1;

__END__
