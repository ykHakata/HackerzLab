# NAME

HackerzLab - ホワイトハッカー育成、トレーニングゲームシステム

# URL

開発用暫定サイト

<https://hackerz-lab.herokuapp.com> - heroku による試験用 (変更になることがあります)

# LOCAL

お手元の開発環境にて

## INSTALL

環境構築、準備

### git clone

お手元の PC に任意のディレクトリを準備後、 github サイトよりリポジトリを取得

<https://github.com/ykHakata/HackerzLab> - HackerzLab / github サイト

```bash
# 例: ホームディレクト配下に github 用のディレクトリ作成
$ mkdir ~/github

# github ディレクトリ配下に HackerzLab リポジトリ展開
$ cd ~/github
$ git clone git@github.com:ykHakata/HackerzLab.git
```

### Perl install

```bash
# 5.24.0 を使用
$ cd ~/github/HackerzLab/
$ cat .perl-version
5.24.0
```

plenv を活用し、perl 5.24.0, cpnam, carton までのインストールを実行

手順の参考

<https://github.com/ykHakata/Summary/blob/master/perl5_install.md> - perl5_install / perl5 ローカル環境での設定手順

### Mojolicious install

Mojolicious を始めとする必要なモジュール一式のインストール実行

```bash
# cpanfile に必要なモジュール情報が記載
$ cd ~/github/HackerzLab/
$ cat cpanfile
requires 'Mojolicious', '== 7.11';

# carton を使いインストール実行
$ carton install

```

## START APP

アプリケーションスタート

通常の設定だと、コマンドラインで morbo サーバー実行後、web ブラウザ `http://localhost:3000/` で確認可能


```bash
# WEBフレームワークを起動 (development モード)
$ carton exec -- morbo script/hackerz_lab

# WEBフレームワークを起動 (testing モード)
$ carton exec -- morbo --mode testing script/hackerz_lab
```

テストコードを実行

```bash
# テストコードを起動の際は mode を切り替え (DBの内容を更新するようなテストの場合は mode を使い分けた方がよい)
$ carton exec -- script/hackerz_lab test --mode testing

# テスト結果を詳細に出力
$ carton exec -- script/hackerz_lab test -v --mode testing

# テスト結果を詳細かつ個別に出力
$ carton exec -- script/hackerz_lab test -v --mode testing t/hackerz_lab.t
```

シンタックスチェック

```bash
# コマンドを実行するディレクトリに注意 (HOME/github はお使いの環境によってことなります)
$ pwd
/Users/HOME/github/HackerzLab/lib

$ carton exec -- perl -c ./HackerzLab.pm
./HackerzLab.pm syntax OK
```
