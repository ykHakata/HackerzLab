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
    my $msg        = $self->db->message;

    $validation->input( $self->req_params );

    $validation->required('login_id')->size( 1, 100 );
    $validation->required('password')->size( 1, 100 );

    $self->validation_set_error_msg(
        +{  login_id => [ $msg->column('STAFF_LOGIN_ID') ],
            password => [ $msg->column('STAFF_PASSWORD') ],
        }
    );
    return $validation;
}

# 新規登録パラメーターバリデート
sub validation_admin_staff_store {
    my $self      = shift;
    my $validator = Mojolicious::Validator->new;
    my $msg       = $self->db->message;

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
        +{  login_id  => [ $msg->column('STAFF_LOGIN_ID') ],
            password  => [ $msg->column('STAFF_PASSWORD') ],
            authority => [ $msg->column('STAFF_AUTHORITY') ],
            name      => [ $msg->column('ADDRESS_NAME') ],
            rubi      => [ $msg->column('ADDRESS_RUBI') ],
            nickname  => [ $msg->column('ADDRESS_NICKNAME') ],
            email     => [ $msg->column('ADDRESS_EMAIL') ],
        }
    );
    return $validation;
}

# 更新登録パラメーターバリデート
sub validation_admin_staff_update {
    my $self      = shift;
    my $validator = Mojolicious::Validator->new;
    my $msg       = $self->db->message;

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
        +{  id         => [ $msg->column('STAFF_ID') ],
            address_id => [ $msg->column('ADDRESS_ID') ],
            name       => [ $msg->column('ADDRESS_NAME') ],
            rubi       => [ $msg->column('ADDRESS_RUBI') ],
            nickname   => [ $msg->column('ADDRESS_NICKNAME') ],
            email      => [ $msg->column('ADDRESS_EMAIL') ],
        }
    );
    return $validation;
}

1;

__END__
