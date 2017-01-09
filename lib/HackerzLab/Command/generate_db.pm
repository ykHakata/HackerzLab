package HackerzLab::Command::generate_db;
use Mojo::Base 'Mojolicious::Command';
use Mojo::Util qw{encode};
use File::Temp;
binmode STDIN,  ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';

has description => 'HackerzLab create database';
has usage => sub { encode( shift->extract_usage ) };
has [qw{csv_files_delete_header index_sample_data sqlite_cmd}];

sub run {
    my $self = shift;

    # start generate_db
    $self->_start_generate_db();
    return;
}

# TODO: model 層をまだ実装していなので、暫定にてここにロジックを記載
# start generate_db
sub _start_generate_db {
    my $self = shift;
    my $conf = $self->app->config;

    # sqlite 以外はまだ対応していません
    die 'not existence database_app' if !$conf->{database_app};
    die 'not support database_app'   if $conf->{database_app} ne 'sqlite';

    # データベース作成
    $self->_create_database_sqlite3();

    # データベーススキーマー作成
    $self->_initialize_schema_sqlite3();

    # サンプルデーター読み込み
    $self->_import_sample_data_sqlite3();
    return;
}

# sqlite の場合
sub _create_database_sqlite3 {
    my $self = shift;
    my $conf = $self->app->config;

    # すでに存在する場合はそのままなにもしない
    return if -f $conf->{database_file};
    $self->write_file( $conf->{database_file}, '' );
    return;
}

sub _initialize_schema_sqlite3 {
    my $self = shift;
    my $conf = $self->app->config;

    my $db     = $conf->{database_file};
    my $schema = $conf->{schema_file};
    die 'not existence schema file' if !-f $schema;

    # 例: sqlite3 ./hackerz.development.db < ./hackerz_schema.sql
    my $cmd = "sqlite3 $db < $schema";

    # system コマンドは失敗すると true になる
    system $cmd and die "Couldn'n run: $cmd ($!)";
    return;
}

# サンプルオリジナルデータからコピーファイルを作成
sub _create_tmp_sample_data {
    my $self = shift;
    my $conf = $self->app->config;

    # コピーとオリジナルを紐づける情報
    my $index_sample_data = [];

    # オリジナル csv の数だけ /tmp にコピー保存
    while ( my ( $key, $value ) = each %{ $conf->{sample_data} } ) {
        my $table    = $key;
        my $csv_file = $value;

        # オリジナルファイル
        my $csv_org_fh = IO::File->new( $csv_file, '<' )
            or die "can't open '$csv_file': $!";

        # tmp ファイル
        my $csv_tmp_fh = File::Temp->new(
            DIR    => $self->app->config->{tmp},
            SUFFIX => '.csv',
            unlink => 0,
        );

        my $file_names = +{
            table => $table,
            org   => $csv_file,
            tmp   => $csv_tmp_fh->filename,
        };
        push @{$index_sample_data}, $file_names;

        # カラム情報を削除 (最初の2行不要)
        while ( my $row = <$csv_org_fh> ) {
            next if $. <= 2;
            chomp $row;
            $csv_tmp_fh->say($row);
        }
        $csv_tmp_fh->close;
        $csv_org_fh->close;
    }
    $self->index_sample_data($index_sample_data);
    return;
}

sub _create_sqlite_cmd {
    my $self = shift;

    # ファイル名から sqlite コマンド作成
    my $sqlite_cmd = '.separator ,' . "\n";

    # データインデックスから sqlite import 情報作成
    for my $file_index ( @{ $self->index_sample_data } ) {
        my $csv_file_org = $file_index->{org};
        my $csv_file_tmp = $file_index->{tmp};
        my $table        = $file_index->{table};
        $sqlite_cmd .= qq{.import $csv_file_tmp $table} . "\n";
    }
    $self->sqlite_cmd($sqlite_cmd);
    return;
}

sub _import_sample_data_sqlite3 {
    my $self = shift;
    my $conf = $self->app->config;

    # サンプルオリジナルデータからコピーファイルを作成
    $self->_create_tmp_sample_data();

    # ファイル名から sqlite コマンド作成
    $self->_create_sqlite_cmd();

    # sqlite コマンドファイル作成、実行
    my $sqlite_cmd_fh = File::Temp->new(
        DIR    => $self->app->config->{tmp},
        SUFFIX => '.txt',
    );
    $sqlite_cmd_fh->print($self->sqlite_cmd);

    my $sqlite_cmd_file = $sqlite_cmd_fh->filename;
    my $db              = $conf->{database_file};

    # 例: sqlite3 ./hackerz.development.db < ./sqlite_cmd.txt
    my $cmd = "sqlite3 $db < $sqlite_cmd_file";
    system $cmd and die "Couldn'n run: $cmd ($!)";

    # 使用済みファイル削除
    $sqlite_cmd_fh->close;
    $self->_delete_tmp_files;
    return;
}

# 使い終わったファイル削除
sub _delete_tmp_files {
    my $self = shift;
    for my $file_index ( @{ $self->index_sample_data } ) {
        my $csv_file_tmp = $file_index->{tmp};
        next if !-f $csv_file_tmp;
        unlink $csv_file_tmp;
    }
    return;
}

1;

__END__

=encoding utf8

=head1 NAME

HackerzLab::Command::generate_db - HackerzLab create database

=head1 SYNOPSIS

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

=head1 DESCRIPTION

=cut
