# NAME

```
deploy - デプロイメントについて
```

# SYNOPSIS

## URL

### 公式サイト

- SAKURA internet - <https://www.sakura.ad.jp/>

### ログイン

- さくらインターネット 会員認証 - <https://secure.sakura.ad.jp/auth/login>
- vps 会員IDでログイン - <https://secure.sakura.ad.jp/vps/#/login>
- vps IPアドレスでログイン - <https://secure.sakura.ad.jp/vps/#/login?method=ip>

```
各認証に必要な ID password 情報は別途
```

### サーバー情報

- vps: tk2-257-38266.vs.sakura.ne.jp
- v4: 160.16.231.20
- v6: 2001:e42:102:1817:160:16:231:20

### マニュアル

- さくらのサポート情報 > VPS - <https://help.sakura.ad.jp/hc/ja/categories/201105252>
- 【さくらのVPS】サーバの初期設定ガイド - <https://help.sakura.ad.jp/hc/ja/articles/206208181>

```
基本的にはこちらのガイドにそって初期設定を行う、この中から手順を抜粋したものを紹介
```

## SETUP

### 各項目についての詳細は `DESCRIPTION` 及び `EXAMPLES` 参照

1. システム再インストール
1. OS の基本設定
1. ユーザー作成
1. 鍵認証の設定
1. セキュリティの設定については別途対応
1. 各ミドルウェアアプリケーションの準備

## DEPLOY

### ソースコードの更新手順

1. github -> ローカル環境へ pull (最新の状態にしておく)
1. ローカル環境 -> github へ push (修正を反映)
1. github -> vpsサーバーへ pull (vpsサーバーへ反映)
1. アプリケーション再起動

```bash
# 現状は開発サーバー、本番サーバーなどの複数の使い分けはしていない
# ローカル環境から各自のアカウントでログイン
$ ssh kusakabe@160.16.231.20

# アプリケーションユーザーに
$ sudo su - hackerzlab

# 移動後、git 更新
$ cd ~/HackerzLab/
$ git pull origin master

# 再起動
$ carton exec -- hypnotoad script/hackerz_lab
```

アプリケーション起動方法その他

```bash
# モード指定しなければ hypnotoad は production で実行される
# 開始 (すぐにデーモン化)
$ carton exec -- hypnotoad script/hackerz_lab

# 開始 (出力待ちの状態で開始)
$ carton exec -- hypnotoad --foreground script/hackerz_lab

# 再起動 (開始している状態でまた同じことを入力)
$ carton exec -- hypnotoad script/hackerz_lab

# 停止
$ carton exec -- hypnotoad --stop script/hackerz_lab

# 起動のテストして終了 (テストコードが実行されるわけではない)
$ carton exec -- hypnotoad --test script/hackerz_lab
```

# DESCRIPTION

## SETUP についての注意事項

### 入力値に関しては事前にルールを決めておく

- root のパスワード (ASCII文字, 8文字以上, 数字と組み合わせ)
- 一般ユーザー名 (ASCII文字, 小文字, 使う人の名前)
- 一般ユーザーパスワード (ASCII文字, 8文字以上, 数字と組み合わせ)
- アプリケーション用の一般ユーザー名 (ASCII文字,  小文字, アプリケーション名)
- 一般ユーザーパスワード (ASCII文字, 8文字以上, 数字と組み合わせ)

### パスワード類の管理について

- 初期パスワードは各自変更する
- パスワード類の管理はキーチェーンなどのアプリを活用するか完全に記憶する

## DEPLOY についての注意事項

### アプリケーションユーザーへのアクセス

- 各自のユーザーへアクセス後にアプリケーションユーザーにアクセス

```bash
$ sudo su - hackerzlab
```

### github への更新

- 現状は開発者が少数につき、常に master に push
- コンフリクトは必ず解消した状態で master に push

# EXAMPLES

## SETUP 例

### システム再インストール

vps IPアドレスでログイン - <https://secure.sakura.ad.jp/vps/#/login?method=ip>

```
IP: 160.16.231.20
password: 別途参照
```

サーバ情報の名前と説明を追加

```
各種設定 -> サーバー情報編集
名前: hackerzlab
説明: クイズシステムを中心とした統合された hackerzlab コミュニティーのためのシステム
```

OS を再インストールする

```
各種設定 -> OS インストール -> 標準 OS インストール
新しい root パスワード入力 (8文字以上、半角英数組合せ)
標準 OS の CentOS6 選択
稼働中の表示が出るまで待機
```

### OS の基本設定

ローカルより vps サーバーへアクセス

```
# はスーパーユーザー
$ は一般ユーザー

ターミナルでアクセス、パスワードで ssh 接続
( ~/.ssh/known_hosts に過去の接続情報がある場合は注意、履歴削除 )

$ ssh root@160.16.231.20

The authenticity of host '160.16.231.20 (160.16.231.20)' ...
...  (yes/no)?

(接続続行を尋ねてくるので yes)

Warning: Permanently added '160.16.231.20' (RSA) to the list of known hosts.

(known_hosts に履歴が追加)

root@160.16.231.20's password:

(パスワードを入力)

SAKURA Internet [Virtual Private Server SERVICE]

[root@tk2-257-38266 ~]#

(ログイン成功)
```

CentOS を最新の状態にしておく

```
[root@tk2-257-38266 ~]# yum update

(途中で何度か [y/n] と聞いてくるが y で入力)

...
Complete!
[root@tk2-257-38266 ~]#
```

CentOS バージョン確認

```
[root@tk2-257-38266 ~]# cat /etc/issue
CentOS release 6.9 (Final)
Kernel \r on an \m
```

日本語化

```
[root@tk2-257-38266 ~]# man man

(man コマンドのオンラインマニュアルが表示、英語表示になっている q で画面を抜ける)

[root@tk2-257-38266 ~]# vim /etc/sysconfig/i18n

LANG="C"
SYSFONT="latarcyrheb-sun16"

(これを...)

LANG="ja_JP.UTF-8"
SYSFONT="latarcyrheb-sun16"

(ファイル保存後、再起動)
[root@tk2-257-38266 ~]# service network restart

(日本語で表示になっている)
[root@tk2-257-38266 ~]# man man
```

### ユーザー作成

一般ユーザー (アプリケーション用ユーザー) の作成

```
ユーザーを作るコマンドは管理者権限で行う

一般ユーザーを作るコマンド
useradd

マニュアル
man useradd

ユーザーID: hackerzlab
password:  (8文字以上、半角英数組合せ)
```

root でログイン状態

```
(ユーザー名設定)
[root@tk2-257-38266 ~]# useradd hackerzlab

(パスワード設定 passwd につづけてユーザー名を指定)
[root@tk2-257-38266 ~]# passwd hackerzlab

(パスワード入力)

(一般ユーザーでも管理者と同様のことをできるように設定 sudo)
[root@tk2-257-38266 ~]# usermod -G wheel hackerzlab

[root@tk2-257-38266 ~]# visudo

(検索する)
/wheel

(エイスケープ # を外して有効にする)
%wheel ALL=(ALL) ALL

保存(esc 押して : )
wq

[root@tk2-257-38266 ~]# exit
(ログアウト)
```

一般ユーザーでアクセス確認 (ローカルから vps へ)

```
$ ssh hackerzlab@160.16.231.20
hackerzlab@160.16.231.20's password:

( hackerzlab のパスワード入力 )

SAKURA Internet [Virtual Private Server SERVICE]

[hackerzlab@tk2-257-38266 ~]$

(ログイン完了)

(念のため今いる場所を確認)

$ pwd
/home/hackerzlab
```

一般ユーザー (作業用ユーザー) の作成

```
ユーザーの作成は管理者権限が必要なので sudo コマンドを活用
ユーザーID: kusakabe
password: (8文字以上、半角英数組合せ)
```

hackerzlab でログイン状態

```
[hackerzlab@tk2-257-38266 ~]$ sudo useradd kusakabe

We trust you have received ...
...
[sudo] password for hackerzlab:
(自分のパスワードを入力)

(以降はアプリケーションユーザー作成の時と同じ手順)
$ sudo passwd kusakabe
$ sudo usermod -G wheel kusakabe
(パスワード入力)
$ exit
(ログアウト)
(上記の手順で必要なだけユーザーを作成)
```

一般ユーザーでアクセスしたあと、アプリケーションユーザーに変身するやり方

```
$ ssh kusakabe@160.16.231.20

SAKURA Internet [Virtual Private Server SERVICE]

[kusakabe@tk2-257-38266 ~]$
(kusakabe でログインしている)

[kusakabe@tk2-257-38266 ~]$ sudo su - hackerzlab

We trust you have received ...
...
[sudo] password for kusakabe:
(kusakabe のパスワード入力)

[hackerzlab@tk2-257-38266 ~]$

(アプリケーションユーザー hackerzlab としてログインしている)
(アプリの更新などは hackerzlab ユーザーに変身してから行う)
(ログアウトも2回)

[hackerzlab@tk2-257-38266 ~]$ logout
[kusakabe@tk2-257-38266 ~]$ logout
Connection to 160.16.231.20 closed.
```

登録ユーザーの一覧を確認するには？

```
$ getent passwd
```

### 鍵認証の設定

#### さくら VPS サーバーとローカル環境 (Mac)

1. 鍵を準備
1. ローカル側(mac)で鍵のペアを生成 -> (秘密鍵、公開鍵)
1. 公開鍵 -> さくらVPS側に転送
1. 秘密鍵 -> ローカル側 (mac) 保存

さくら VPS 側に公開鍵の保管場所を作成

```
$ ssh kusakabe@160.16.231.20
(ssh でパスワード認証で一旦アクセス)

$ pwd
/home/kusakabe
(今いる場所)

$ ls -a
.  ..  .bash_history  .bash_logout  .bash_profile  .bashrc  .viminfo
(現在のディレクトリ状況確認)

$ mkdir ~/.ssh
(鍵を保管するディレクトリを作成)

$ chmod 700 ~/.ssh
(パーミッションを変更)

```

鍵の準備

```
もう一つタブを開き、ローカル側で鍵のペアを作る前にすでに作られているかを確認

ローカル側(mac)に移動
$ ls -a ~/.ssh/
.       config      id_rsa.pub
..      id_rsa      known_hosts

すでに存在するので今回はそのまま流用

id_rsa -> (秘密鍵)
id_rsa.pub -> (公開鍵)

$ chmod 600 ~/.ssh/id_rsa.pub
(念の為にパーミッションを変更)

(ファイルをさくらVPS側に転送 scp コマンドを使い、同時にファイル名も変更)
$ scp ~/.ssh/id_rsa.pub kusakabe@160.16.231.20:~/.ssh/authorized_keys

(二つ目を追記したい場合はこちらのやり方)
$ cat ~/.ssh/id_rsa.pub | ssh kusakabe@160.16.231.20 'cat >> ~/.ssh/authorized_keys'

kusakabe@160.16.231.20's password:
(パスワード入力)

id_rsa.pub                                              100%  401    11.4KB/s   00:00
(転送完了)
```

さくら VPS でファイルが転送できているか確認

```
$ ls -a ~/.ssh/
.  ..  authorized_keys
(authorized_keys のファイルの中に公開鍵が収められてる)

$ exit
(ログアウト)
```

鍵認証でログイン

```
$ ssh -i ~/.ssh/id_rsa kusakabe@160.16.231.20
(ローカル(mac)から鍵をつかってログイン)

[kusakabe@tk2-257-38266 ~]$

$ exit
(ログアウト)

$ ssh kusakabe@160.16.231.20
(ローカル(mac)から鍵をつかってログイン -> 省略して入力)
(デフォルトでは ~/.ssh/id_rsa を見るようになっている)

[kusakabe@tk2-257-38266 ~]$

$ exit
(ログアウト)

本来はセキュリティーを高めるために ssh や
ファイアーウォールの設定を調整する必要があるが今回はここまで。
```

#### さくら VPS サーバーと Github

1. さくら vps サーバー側で鍵のペアを生成 -> (秘密鍵、公開鍵)
1. 公開鍵 -> Github 側に転送
1. 秘密鍵 -> 開発サーバー (さくらvps側) 保存

開発サーバー (さくらVPS)

```
$ ssh kusakabe@160.16.231.20

$ sudo su - hackerzlab

$ pwd
/home/hackerzlab
(今いる場所)

$ ls -a
.  ..  .bash_history  .bash_logout  .bash_profile  .bashrc
(現在のディレクトリ状況確認)

$ mkdir ~/.ssh
(鍵を保管するディレクトリを作成)

$ chmod 700 ~/.ssh
(パーミッションを変更)

$ ssh-keygen -t rsa -C 'hackerzlab'
(さくら VPS 側で鍵の生成、いろいろ聞かれるがすべてリターン)

$ ls -a ~/.ssh/
.  ..  id_rsa  id_rsa.pub

(id_rsa -> 秘密鍵 id_rsa.pub -> 公開鍵)
```

Github に公開鍵を登録

```
Github サイトの右上アイコン、プルダウン -> Settings
SSH and GPG keys -> SSH keys
New SSH key クリック

Title -> hackerzlab
key -> 公開鍵の内容をコピペする

$ cat ~/.ssh/id_rsa.pub
(cat コマンドで標準出力し内容をコピペ)

貼り付ける範囲は
ssh-rsa ... から
== '任意のコメント' 改行
まで

パスワードを聞かれるのでgithubのパスワード入力
```

接続の確認

```
[hackerzlab@tk2-257-38266 ~]$ ssh -T git@github.com
The authenticity of host 'github.com (192.30.255.113)' ...
... connecting (yes/no)? yes

(yes と入力)

Warning: Permanently added 'github.com,192.30.255.113' (RSA) to the list of known hosts.

(known_hosts に履歴が追加)

Hi ykHakata! You've successfully authenticated, but GitHub does not provide shell access.
(Github と接続ができたメッセージ)
```

### セキュリティの設定については別途対応

### 各ミドルウェアアプリケーションの準備

git の確認

```bash
$ git --version
git version 1.7.1
```

plenv インストール

```bash
$ git clone git://github.com/tokuhirom/plenv.git ~/.plenv

$ echo 'export PATH="$HOME/.plenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(plenv init -)"' >> ~/.bash_profile
$ exec $SHELL -l

$ git clone git://github.com/tokuhirom/Perl-Build.git ~/.plenv/plugins/perl-build/

$ plenv --version
plenv 2.2.0-14-gb2ea2fd
```

Perl インストールと設定

```bash
$ plenv install --list

# 開発で利用しているバージョン 5.24.0
$ plenv install 5.24.0
$ plenv rehash

$ plenv versions
* system (set by /home/hackerzlab/.plenv/version)
  5.24.0

$ plenv global 5.24.0

$ plenv versions
  system
* 5.24.0 (set by /home/hackerzlab/.plenv/version)
```

cpanm インストール

```bash
$ plenv install-cpanm
```

carton インストール

```bash
$ cpanm Carton
$ carton -v
carton v1.0.28
```

github のソースコードを配置

```bash
$ cd ~/HackerzLab/
$ git clone git@github.com:ykHakata/HackerzLab.git

# carton を使い必要なモジュール一式インストール
$ carton install

# アプリケーションスタート
$ carton exec -- hypnotoad script/hackerz_lab
```

# FILES

# SEE ALSO

# BUGS

