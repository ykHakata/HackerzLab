package HackerzLab::Command::generate_db;
use Mojo::Base 'Mojolicious::Command';
use Mojo::Util qw{dumper};
binmode STDIN,  ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';

has description => 'HackerzLab create database';
has usage       => <<'END_USAGE';
Usage: carton exec -- script/hackerz_lab generate_db [OPTIONS]

Options:
  -m, --mode   Does something.

  # 開発用 (mode 指定なし) -> /db/hackerz.development.db
  $ carton exec -- script/hackerz_lab generate_db

  # 本番用 -> /db/hackerz.production.db
  $ carton exec -- script/hackerz_lab generate_db --mode production

  # テスト用 -> /db/hackerz.testing.db
  $ carton exec -- script/hackerz_lab generate_db --mode testing

  # 開発用 -> /db/hackerz.development.db
  $ carton exec -- script/hackerz_lab generate_db --mode development
END_USAGE

sub run {
    my $self = shift;

    # データベース作成
    $self->_create_database();

    # データベーススキーマー作成
    $self->_initialize_schema();

    # サンプルデーター読み込み
    $self->_import_sample_data();

    return;
}

# TODO: model 層をまだ実装していなので、暫定にてここにロジックを記載
sub _create_database {
    warn '_create_database-----1';
    my $self = shift;
    my $conf = $self->app->config;

    # sqlite 以外はまだ対応していません
    die 'not existence database_app' if !$conf->{database_app};
    die 'not support database_app'   if $conf->{database_app} ne 'sqlite';
    $self->_create_database_sqlite3();
    return;
}

# sqlite の場合
sub _create_database_sqlite3 {
    my $self = shift;
    my $conf = $self->app->config;

    my $database_dir  = $conf->{database_dir};
    my $database_name = $conf->{database_name};
    my $mode          = $self->app->mode;

    my $file = qq{$database_dir/$database_name.$mode.db};

    # すでに存在する場合はそのままなにもしない
    $self->write_file( $file, '' );
    return;
}

sub _initialize_schema {
    warn '_initialize_schema-----1';
    return;
}

sub _import_sample_data {
    warn '_import_sample_data-----1';
    return;
}

1;

__END__
