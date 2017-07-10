package HackerzLab::DB::Message;
use Mojo::Base 'HackerzLab::DB::Base';
use Mojo::Util qw{dumper};

sub column {
    my $self  = shift;
    my $value = shift;
    die 'message column value: ' if !defined $value;
    my $hash = +{
        STAFF            => '管理ユーザー',
        STAFF_ID         => '管理ユーザーID',
        STAFF_LOGIN_ID   => 'ログインID',
        STAFF_PASSWORD   => 'ログインパスワード',
        STAFF_AUTHORITY  => '管理者権限',
        ADDRESS          => '住所',
        ADDRESS_ID       => '住所ID',
        ADDRESS_STAFF_ID => '管理ユーザーID',
        ADDRESS_NAME     => '名前',
        ADDRESS_RUBI     => 'ふりがな',
        ADDRESS_NICKNAME => 'ニックネーム',
        ADDRESS_EMAIL    => 'Eメール',
    };
    return $hash->{$value};
}

sub error {
    my $self  = shift;
    my $value = shift;
    die 'message error value: ' if !defined $value;
    my $hash = +{
        DUPLICATION_LOGIN_ID =>
            '入力されたログインID(email)はすでに登録済みです',
        NOT_EXIST_LOGIN_ID => 'ログインID(email)が存在しません',
        NOT_EXIST_PASSWORD => 'ログインパスワードがちがいます',
    };
    return $hash->{$value};
}

sub common {
    my $self  = shift;
    my $value = shift;
    die 'message error value: ' if !defined $value;
    my $hash = +{
        DONE_LOGIN             => 'ログインしました',
        DONE_STORE             => '新規登録完了しました',
        DONE_UPDATE            => '編集登録完了しました',
        DONE_REMOVE            => '削除完了しました',
        NOT_EXIST_STAFF        => '存在しないユーザー',
        NOT_EXIST_STAFF_SEARCH => '検索該当がありません',
    };
    return $hash->{$value};
}

1;

__END__

my $msg = $self->db->message;

# '入力されたログインID(email)はすでに登録済みです'
my $error_msg = $msg->error('DUPLICATION_LOGIN_ID');

# 'ログインパスワード'
my $column_name = $msg->column('STAFF_PASSWORD');

# '新規登録完了しました'
my $common_msg = $msg->common('DONE_STORE');
