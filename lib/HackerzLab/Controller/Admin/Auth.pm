package HackerzLab::Controller::Admin::Auth;
use Mojo::Base 'Mojolicious::Controller';
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
    my $admin_auth = $self->model->admin->auth;

    # バリデーション (後ほど実装)

# TODO: 暫定、失敗時は公式トップへリダイレクト、後ほどフィルインにする

    # 認証作業一式のはじまり
    return $self->redirect_to('/') if !$admin_auth->create($params);

    # staff, login_id 存在確認
    return $self->redirect_to('/') if !$admin_auth->exists_login_id();

    # password 照合
    return $self->redirect_to('/') if !$admin_auth->check_password();

    # セッション用 id 暗号化
    $admin_auth->encrypt_exec_session_id();

    # セッション埋め込み実行
    $self->session( login_id => $admin_auth->encrypt_session_id() );

    # ログイン成功メッセージ埋め込み
    $self->flash( msg => $admin_auth->login_row->login_id );

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
