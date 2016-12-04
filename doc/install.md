# 環境構築


## git クローン
git clone https://github.com/ykHakata/HackerzLab.git

cd HackerzLab


## WEBフレームワークMojoliciousをインストール

cartonを使用する

touch cpanfile
vim cpanfile
requires 'Mojolicious', '== 7.11';

carton install

cpanfileの書き方(例)

requires 'Module::Name';
requires 'Module::Name', 'MINIMUM VERSION';
requires 'Module::Name', '>= MINIMUM, < MAXIMUM';
requires 'Module::Name', '== SPECIFIC VERSION';


carton exec をつけなければいけない事に注意

## mojoコマンドででひな形作成
carton exec mojo generate app HackerzLab

HackerzLab が hackerz_lab の用に変化する事に注意

## ディレクトリ構造を整える

HackerzLab内のファイル一式を移動
mv hackerz_lab/* .

空ディレクトリを削除
rmdir hackerz_lab


## gitで履歴をとらないファイルを設定

隠しファイルの .gitignore に設定するディレクトリ名、ファイル名を指定

touch .gitignore

カートンでインストールしたモジュール一式
echo local/ >> .gitignore

ログファイル一式
echo log/ >> .gitignore


## gitアカウントの設定

git config --list

git config --local user.name "sk39kii"
git config --local user.email "sk39kii@gmail.com"


## docフォルダの作成

mkdir doc

## GitHubにPush
・ためしに、ローカルでファイルを更新して、git push する

ドキュメントを保存するためのディレクトリをつくりましょう。

HackerzLab ディレクトリを / として。

```bash
# /doc ディレクトリを作成します。
$ mkdir doc
```

github への push の第一弾として、環境構築のドキュメントをつくります。
ファイル名は install.md ということにしましょう。

マークダウン形式で slack に私が書いたメモをとりあえずコピペしてファイル保存します。

```bash
# 3ステップで
git add .
git commit -m 'install.md 追加 #1'
git push origin master
# コミットの文に #1 をくわえるとイシューの番号にひもづきます。
```

https://github.com/ykHakata/HackerzLab/issues/1
で確認してみます。
