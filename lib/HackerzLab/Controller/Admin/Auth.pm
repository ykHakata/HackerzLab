package HackerzLab::Controller::Admin::Auth;
use Mojo::Base 'HackerzLab::Controller';
use Mojo::Util qw{dumper};

# This action will render a template
sub index {
    my $self = shift;

    $self->render( template => 'admin/login' );
    return;
}

sub login {
    my $self = shift;

    my $params     = $self->req->params->to_hash;
    my $admin_auth = $self->model->admin->auth->create($params);
    my $msg        = $admin_auth->db->message;

    # バリデート
    $admin_auth->validator_customize('admin_auth_login');
    my $template = 'admin/login';

    # 失敗、フィルイン、もう一度入力フォーム表示
    if ( $admin_auth->validation_has_error ) {
        $self->stash->{validation_msg} = $admin_auth->validation_msg;
        $self->render_fillin( $template, $admin_auth->req_params );
        return;
    }

    # DB 存在確認
    if ( $admin_auth->is_not_exist_login_id ) {
        $self->stash->{validation_msg}
            = [ $msg->error('NOT_EXIST_LOGIN_ID') ];
        $self->render_fillin( $template, $admin_auth->req_params );
        return;
    }

    # password 照合
    if ( $admin_auth->is_not_exist_password ) {
        $self->stash->{validation_msg}
            = [ $msg->error('NOT_EXIST_PASSWORD') ];
        $self->render_fillin( $template, $admin_auth->req_params );
        return;
    }

    # 合格の値を再配置
    $admin_auth->setup_req_params;

    # セッション用 id 暗号化
    $admin_auth->encrypt_exec_session_id();

    # セッション埋め込み実行
    $self->session( login_id => $admin_auth->encrypt_session_id() );

    # ログイン成功メッセージ埋め込み
    my $flash_msg = $admin_auth->login_id . ' ' . $msg->common('DONE_LOGIN');
    $self->flash( flash_msg => $flash_msg );

    # 管理画面トップへ
    $self->redirect_to('/admin/menu');
    return;
}

sub logout {
    my $self = shift;

    # post ログアウト実行後リダイレクト
    # (大文字で POST で返却されることに注意)
    if ( $self->req->method eq 'POST' ) {
        $self->session( expires => 1 );
        $self->redirect_to('/admin/logout');
        return;
    }

    # get ログアウト画面表示
    $self->render( template => 'admin/logout' );
    return;
}

1;

__END__
