# 環境構築

## Perlのインストール

#### 公式サイト

* https://github.com/tokuhirom/plenv

#### 参考サイト

* http://www.omakase.org/perl/plenv.html
* http://blog.papix.net/entry/2013/06/04/081554
* http://perldoc.jp/docs/articles/github.com/tokuhirom/plenv/blob/master/README.md


### plenvのインストール確認

ターミナルを起動し以下のコマンドを実行

```sh
## plenvのインストール確認(バージョンが表示されればplenvはインストール済み)
plenv -version
```

### plenvのインストール

ターミナルを起動しホームディレクトリで以下のコマンドを実行

```sh
git clone git://github.com/tokuhirom/plenv.git ~/.plenv

echo 'export PATH="$HOME/.plenv/bin:$PATH"' >> ~/.bash_profile

echo 'eval "$(plenv init -)"' >> ~/.bash_profile

exec $SHELL -l

git clone git://github.com/tokuhirom/Perl-Build.git ~/.plenv/plugins/perl-build/
```
### Perlのインストール

今回は最新の安定 5.24 をインストールする  
(この段階ではplenvにPerl5.24.0をインストールしているだけ)
```sh
plenv install 5.24.0
plenv rehash
```

plenvでインストールしたバージョンを指定する。  
(これでマシン全体で使用するPerlがこのバージョンになる)

```sh
plenv global 5.20.2
```

バージョンの確認

```sh
plenv versions
system
* 5.24.0 (set by /Users/sk/.plenv/version)
```


## cpanmのインストール

cpanmは、CPANモジュール用のコマンドラインツール

```sh
plenv install-cpanm
```

インストール後確認

```sh
which cpanm
/Users/sk/.plenv/shims/cpanm
```

## モジュール追加

### Carton(cpanモジュールを管理する)

```sh
cpanm Carton
```

インストール後確認

```sh
carton -v
carton v1.0.28
```

#### 参考サイト

* https://metacpan.org/pod/Carton

### Perl:Tidy(ソースコードを整形する)

```sh
cpanm Perl::Tidy

```

インストール後確認

```sh
perltidy -v

This is perltidy, v20160302 

Copyright 2000-2016, Steve Hancock

Perltidy is free software and may be copied under the terms of the GNU
General Public License, which is included in the distribution files.

Complete documentation for perltidy can be found using 'man perltidy'
or on the internet at http://perltidy.sourceforge.net.
```

#### 参考サイト

* https://metacpan.org/pod/Perl::Tidy


## リポジトリをローカル環境に git clone する

git リポジトリを復元する任意のディレクトリにて git clone コマンドを実行する。  
以下のサイトの明るい緑のボタンで、 [clone or download] のボタンをクリックすると url が出現するので任意のディレクトリで実行

https://github.com/ykHakata/HackerzLab

```sh
## git clone クリップボードにコピーしたURL
git clone https://github.com/ykHakata/HackerzLab.git
```

HackerzLab というディレクトリが作成されるので、ディレクトリの中へ移動

```sh
cd HackerzLab
```

## WEBフレームワークMojoliciousをインストール
 
Mojoliciousのバージョンは7.11

### cartonを使用してインストール

cpanfileの作成

```sh
touch cpanfile
vim cpanfile
## 以下を書き込み保存する
requires 'Mojolicious', '== 7.11';
```

インストール

```sh
carton install
```

cpanfileの書き方(例)
```sh
requires 'Module::Name';
requires 'Module::Name', 'MINIMUM VERSION';
requires 'Module::Name', '>= MINIMUM, < MAXIMUM';
requires 'Module::Name', '== SPECIFIC VERSION';
```


## Mojoliciousの雛形を作成

ここで、mojo の generater コマンドを実行してひな形をつくる。 

### mojoコマンドででひな形作成
carton exec をつけなければいけない事に注意

```sh
carton exec mojo generate app HackerzLab
```

HackerzLab が hackerz_lab の用に変化する事に注意

### ディレクトリ構造を整える

HackerzLab内のファイル一式を移動する

```sh
mv hackerz_lab/* .
```

空ディレクトリを削除

```sh
rmdir hackerz_lab
```

## Gitで履歴をとらないファイルを設定

隠しファイルの .gitignore に設定するディレクトリ名、ファイル名を指定

```sh
touch .gitignore
```

```sh
## カートンでインストールしたモジュール一式
echo local/ >> .gitignore

## ログファイル一式
echo log/ >> .gitignore
```

## Gitアカウントの設定

設定内容の確認コマンド

```sh
git config --list
```

```sh
git config --local user.name "GitHubのユーザ名"
git config --local user.email "GitHubのメールアドレス"
```


## ドキュメントを保存用のディレクトリを作成

docフォルダの作成する。  
HackerzLab ディレクトリ直下で以下のコマンドを実行する。

```sh
mkdir doc
```

## GitHubにPush

ためしに、ローカルでファイルを更新して、git push する。  
github への push の第一弾として、環境構築のドキュメントを作成する。  
ファイル名は install.md。

```sh
## 以下3ステップで
git add .
git commit -m 'install.md 追加 #1'
git push origin master
## コミットの文に #1 をくわえるとイシューの番号にひもづきます。
```

以下のサイトで確認する  
https://github.com/ykHakata/HackerzLab/issues/1
