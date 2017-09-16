## 0. はじめに

今回は番外編です。これまで学んで得たRubyのスキルを使って、インフラ環境を構築してみようというコンセプトです。  
**インフラのコード化**に取り組んでいきましょう。

以下の事項について順に取り組んでいきます。
* Vagrant  
仮想環境を提供するソフトウェア(VirtualBoxやVMWareなど)のフロントエンドを担当するソフトウェア
* Itamae  
ソフトウェアの構成管理を担当するソフトウェア
* Serverspec
サーバの状態をテストするソフトウェア

お伝え忘れましたが、**今回はCloud9を利用しません。**  
みなさんのお使いのローカルマシンを使っていきます。

## 1. Vagrant+VirtualBoxによる仮想環境構築

![img](img/vagrant-logo.png)

ここでは、VirtualBoxを仮想化ソフトとして、そのフロントエンドツールとしてVagrantを使った環境構築を紹介します。

仮想環境を構築することは、VirtualBoxだけででできるのですが、GUIでネットワークやメモリなどの設定をしてしまうと、他の人が同じ環境を使うのに一苦労であったりします。

Vagrantを使うと、こういった情報をフォーマットに従って、コード化しておくことが簡単にできます。このコーディングは、Rubyで作られたDSLを使って記述できます。

<u>[VirtualBox公式サイト]</u>  
https://www.virtualbox.org/

<u>[Vagrant公式サイト]</u>  
https://www.vagrantup.com/

### 1-1. VirtualBoxでできること、Vagrantでできること

VagrantとVirtualBoxで何がしたいか、まず説明します。

1. 開発環境を構築する際に個人のローカル環境に依存しないようにしたい。
2. すぐに使える仮想環境を構築したい。
3. 環境構築を自動化したい。
4. チームで同一の環境を簡単に構築したい。

<u>**開発環境を構築する際に個人のローカル環境に依存しないようにしたい**</u>  
こちらについては、VirtualBoxだけでも可能です。
開発端末にWindowsを使っている人とMacを使っている人が混在している場合でも、仮想環境でプログラムを実行するようにすれば環境構築手順がほとんど同じになります。

**<u>すぐに使える仮想環境を構築したい</u>**  
これもVirtualBoxだけで可能です。
他の人が作ったVirtualBoxのイメージファイルをインポート、エクスポートすることで実現できます。

しかし、Vagrantを使うと、VirtualBoxを単体で使うよりも効率的に環境構築が可能になります。  
以下のサイトで公開されているBoxイメージをコマンド一発でローカル環境に取り込むことができます。

<u>[Vagrant Cloud]</U>  
https://app.vagrantup.com/boxes/search

また、Vagrantfileと呼ばれるファイルを使ってセットアップすれば、メモリやCPU、仮想環境ネットワークの情報まで再現することが可能です。

Vagrantfileをプロジェクト内のリポジトリやGitHubなどにソースコードとして管理すれば、より効率的に同じ環境を構築可能になります。

**<u>環境構築を自動化したい</u>**  
開発環境を構築する場合、環境構築手順書を参照しながら環境構築するのが、一般的だったと思います。オンプレミスで環境を構築する場合には、特に当てはまるのではないでしょうか。

しかし、これには問題が伴います。  
手順書のフォーマットはプロジェクトごとにバラバラ(ルールに基づくため)であるため、新規参画者にとっては読みづらく、ローカル環境を構築するのにも一苦労です。

Vagrantで仮想環境を構築し、仮想環境上のマシンにChefや、Ansible、Itamaeなどの構成管理ツールでミドルウェアやOSユーザの設定をDSLが提供するフォーマットに従ってコード化すれば、コマンドで簡単構築できます。

**<u>チームで同一の環境を簡単に構築したい</u>**  
ネットワーク上のに存在するリポジトリにVagrantfileを保存しておけば、以下のような流れで、チーム内のメンバが簡単に同じ環境を構築可能です。

1. だれかが、仮想マシンをセットアップするまでの情報をVagrantfileに記述、さらにミドルウェアやOSユーザの情報などを構成管理ツールのレシピファイルを開発用のリポジトリに保存しておく。
2. 他のメンバーは、開発用のリポジトリに保存されたVagrantfileやレシピファイルをクローン(またはダウンロード)する。
3. 他のメンバーは、Vagrantfileを使って、仮想マシンを起動する。
4. 他のメンバーは、レシピファルを仮想マシンに適用し、ミドルウェアの設定などを実施。

といったように、インフラ、ミドルウェアの設定情報をコード化しておき、共有しておけば、手順書にしたがって環境を構築するよりも、コマンドを数本じっこうするだけで遥かに簡単に環境を構築できるわけです。

前置きはこのくらいにして、VagrantとVirtualBoxを使って、仮想マシンをセットアップしてみましょう。

### 1-1. VirtualBoxとVagrantのインストール

**VirtualBoxのインストール**  
以下のページより、現在使用しているマシンにあったファイルをダウンロードし、インストールしてください。特に迷うところはないと思います。

https://www.virtualbox.org/wiki/Downloads

インストール後、ターミナルを起動して以下のコマンドを実行できれば成功です。

```bash
$ VBoxManage -v
5.1.22r115126 # 2017.8時点でのバージョンは5.1.26になります。
```

お伝え忘れましたが、vagrantを操作するコマンドは、すべて`vagrant`から始まるコマンドになります。大事なことなので、覚えておくとよいでしょう。

### 1-2. boxのダウンロード

早速、仮想マシンの元となるイメージファイル(box)をダウンロードしてみましょう。  
今回は、`CentOS7`のイメージファイル(box)を公式サイトのVagrant Cloudからダウンロードします。  
この**boxダウンロード作業は初回のみ**になります。以降は、このboxを使って仮想マシンを複数台セットアップしていきます。

```
# Vagrant Cloudからcentos/7をダウンロード
$ vagrant box add centos/7
...
==> box: Successfully added box 'centos/7' (v20170811.0.1) for 'virtualbox'!
```

ここで、`centos/7` という表記がありますが、これはVagrant Cloudで提供してくれている表記に基づいています。  
Vagrant Cloudで提供しているboxは、こちらを参照ください。いろいろあります。

<u>[Vagrant Cloud]</u>  
https://app.vagrantup.com/boxes/search

インストールが完了したら、boxが追加されたかどうか確認するために、以下のコマンドを使って確認してください。表示されればOKです。

```bash
$ vagrant box list
centos/7                  (virtualbox, 1704.01)
```

### 1-3. 仮想マシンの起動

取り込んだ`centos/7`のboxを使って、仮想マシンを起動してみましょう。  
その前に、作業用のディレクトリを作成しておきましょう。  
**このディレクトリが今後の作業の起点になります。**

```bash
$ mkdir ~/Desktop/test-box
$ cd ~/Desktop/test-box
```

つづいて、`Vagrantfile`を作成します。

```bash
$ vagrant init centos/7
```

`Vagrantfile`からコメントアウトを除く部分を持ってくると、以下のようになっています。

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
end
```

とりあえずは`Vagrantfile`をこのままにして、仮想マシンを起動してみましょう。  
起動は簡単です。`Vagrantfile`が存在するディレクトリで以下のコマンドを実行してください。

```bash
$ vagrant up

Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'centos/7'...
...
==> default: Rsyncing folder: /Users/nagakuray/Desktop/test-box/ => /vagrant
```

仮想マシンが起動したかどうか確認するために、以下のコマンドで確認してください。
ステータスが`running (virtualbox)`になっていればOKです。  
また、上記のマシン名を指定しない`Vagrantfile`の設定の場合、マシン名は`default`になります。

```bash
$ vagrant status
Current machine states:

default                   running (virtualbox)
```

ここまででわかると思いますが、拍子抜けするぐらい簡単ですね！

### 1-3. vagrantコマンドによるログイン

仮想マシンの起動が完了したら、早速ログインしてみましょう。  

`vagrant ssh [マシン名]`でログインできます。
現在はマシン名が`default`のマシンが起動していますので、以下でログインできます。  
**vagrantコマンドを使わないsshでのログイン方法については、あとで説明します。**

```bash
$ vagrant ssh default
[vagrant@localhost ~]$
Linux localhost.localdomain 3.10.0-514.16.1.el7.x86_64 #1 SMP Wed Apr 12 15:04:24 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
```

ログインが確認できたら`exit`で抜けてください。

```bash
[vagrant@localhost ~]$ exit
logout
Connection to 127.0.0.1 closed.
```

### 1-4. 仮想マシンの破棄

仮想マシンを停止して破棄してみましょう。  
vagrantコマンドを使って簡単にできます。

```bash
# 仮想マシンの停止はvagrant halt [マシン名]
$ vagrant halt default

# 仮想マシンの破棄はvagrant destroy [マシン名]
$ vagrant destroy default
```

### 1-5. Vagantfileの編集

ここまでの`Vagrantfile`は、このような状態です。  
IPアドレスやメモリの情報など何も定義されていないですね。  

**Vagrantfile**

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
end
```

`Vagrantfile`を編集していきましょう。  
今回は、以下のように仮想マシンを2台ほど設定します。

**<u>仮想マシン1</u>**

* マシン名: mickey
* ホスト名: mickey
* CPU: 1
* メモリ: 512MB
* IPアドレス: 192.168.10.11

**<u>仮想マシン2</u>**

* マシン名: aradin
* ホスト名: aradin
* CPU: 1
* メモリ: 700MB
* IPアドレス: * IPアドレス: 192.168.10.12

※ IPアドレスは、ホストマシン(皆さんのローカルマシン)と仮想マシンとの間の通信、および仮想マシン間の通信のみが可能なようにします。

早速編集していきましょう。  
編集すると、以下のようになります。

**Vagrantfile**

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # setting for mickey machine
  config.vm.define "mickey" do |node|

    node.vm.box = "centos/7"
    node.vm.hostname = "mickey"

    node.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "512"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end

    node.vm.network "private_network", ip: "192.168.10.11"

  end

  # setting for aradin machine
  config.vm.define "aradin" do |node|

    node.vm.box = "centos/7"
    node.vm.hostname = "aradin"

    node.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "700"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end

    node.vm.network "private_network", ip: "192.168.10.12"

  end

end
```

ポイントについて順を追って解説していきます。

```ruby
Vagrant.configure("2") do |config|
  ...
end
```

Vagrantの設定をするメソッドを呼んでいます。`2`はVagrantのバージョンです。  
`do`~`end`ブロックの間で仮想マシンの設定を定義していきますが、その時のブロックで利用する変数が`config`になります

```ruby
config.vm.define "mickey" do |node|
  ...
end
```

`define`メソッドをブロック付きで呼んでいます。 
メソッドの引数には**仮想マシン名**を与えています。  
`do`~`end`ブロックの間で利用できる変数を`node`として定義しています。

```ruby
node.vm.box = "centos/7"
```

**仮想マシン**で利用するbox名`"centos/7"`を`node.vm.box`という変数に代入しています。

```ruby
node.vm.hostname = "mickey"
```

仮想マシンの**ホスト名**`"mickey"`を`node.vm.hostname`という変数に代入しています。

```ruby
node.vm.provider "virtualbox" do |vb|
  vb.customize ["modifyvm", :id, "--memory", "512"]
  vb.customize ["modifyvm", :id, "--cpus", "1"]
end
```

この部分は、`provider`メソッドをブロック付きで呼んでいます。  
このメソッドは**プロバイダ特有の値**を設定します。  
今回は、VirtualBoxをプロバイダとして利用しているため、メソッドの引数は`"virtualbox"`としています。  
さらに`do`~`end`では、`vb`を変数として、`customize`メソッドを呼び出しています。引数は配列で渡しています。  
今回はメモリサイズとCPU数を設定しています。  
このあたりの設定は、プロバイダであるVirtualBoxの公式ページに掲載されているのですが、わかりにくいです。以下が参考になります。

(参考) [VirtualBox Mania](http://vboxmania.net/content/vboxmanage-modifyvmコマンド)

```ruby
node.vm.network "private_network", ip: "192.168.10.11"
```

ここでは、`network`メソッドを呼んでいます。  
`network`メソッドの引数として、**ネットワークの種類**、**IPアドレス**を渡しています。

ネットワークの種類ですが、ホストマシン(皆さんのローカルマシン)と仮想マシンとの間の通信、および仮想マシン間の通信のみが可能なようにするため、プライベートネットワークとする必要があるので、引数に`"private_network"`を設定しました。
IPアドレスは、シンボルハッシュの形式で`ip: "192.168.10.11"`を渡しています。

説明が長くなってしまったので、`Vagrantfile`を再掲します。

**Vagrantfile**

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # setting for mickey machine
  config.vm.define "mickey" do |node|

    node.vm.box = "centos/7"
    node.vm.hostname = "mickey"

    node.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "512"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end

    node.vm.network "private_network", ip: "192.168.10.11"

  end

  # setting for aradin machine
  config.vm.define "aradin" do |node|

    node.vm.box = "centos/7"
    node.vm.hostname = "aradin"

    node.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "700"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end

    node.vm.network "private_network", ip: "192.168.10.12"

  end

end
```

Vagrantの公式ページには、以下のように記載があります。  
要約すると、「Rubyを知らなくてもVagrantfileは単純な変数割当てだけで書ける」です。  

```
The syntax of Vagrantfiles is Ruby, 
but knowledge of the Ruby programming language is not necessary to make modifications to the Vagrantfile, 
since it is mostly simple variable assignment. In fact, Ruby is not even the most popular community Vagrant is used within, 
which should help show you that despite not having Ruby knowledge, 
people are very successful with Vagrant.
```

たしかにその通りですが、ここまでRubyを学んできたので、Vagrantfileの書き方を知らなくても簡単に設定できるようにアレンジしてみましょう。  
設定情報を`Yaml`ファイル(拡張子は`yml`)に定義して集約してみます。

ディレクトリ構成は、以下のとおりです。

**ディレクトリ構成**

```bash
test-box
├── setting.yml
└── Vagrantfile
```

それでは、ファイルを編集していきましょう。とはいっても、コピペでかまいません。

**setting.yml**

```yml
- vm-name: mickey      # 仮想マシン名
  box: centos/7        # 利用するbox
  hostname: mickey     # ホスト名
  ip: 192.168.10.11    # IPアドレス
  memory: 512          # メモリ
  cpus: 1              # CPU数

- vm-name: aradin
  box: centos/7
  name: aradin
  ip: 192.168.10.12
  memory: 700
  cpus: 1
```

**Vagrantfile**

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
setting_info = YAML.load_file('./setting.yml')

Vagrant.configure("2") do |config|

  setting_info.each do |m|
    config.vm.define m["vm-name"]  do |node|
      node.vm.box = m["box"]
      node.vm.hostname = m["hostname"]
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", m["memory"].to_s]
        vb.customize ["modifyvm", :id, "--cpus", m["cpus"].to_s]
      end
      node.vm.network "private_network", ip: m["ip"].to_s
    end
  end

end
```

`setting.yml`について補足ですが、REPLで確認すると、以下のような感じになっています。  
配列の要素をハッシュで定義しているだけです。

```ruby
> require 'yaml'
> YAML.load_file("./setting.yml")
=> [{"vm-name"=>"mickey",
  "box"=>"centos/7",
  "hostname"=>"mickey",
  "ip"=>"192.168.10.11",
  "memory"=>512,
  "cpus"=>1},
 {"vm-name"=>"aradin",
  "box"=>"centos/7",
  "name"=>"aradin",
  "ip"=>"192.168.1.12",
  "memory"=>700,
  "cpus"=>1}]
```

ここまでできたら、`vagrant up`で仮想マシンを起動してみましょう。  
`vagrant up [マシン名]`とするとマシンを指定して起動できるのですが、単純に`vagrant up`とすると、Vagrantfileに定義されたマシンを全て起動できます。  
今回は後者の方法を使って起動します。

```bash
$ vagrant up
$ vagrant status
```

起動に成功したでしょうか？  
`setting.yml`の設定を変更して、vagrantコマンドだけ実行すればよくなりました。  
ただし、この方法には注意が必要です。  
`setting.yml`の`vm-name`を変更しないようにしてください。変更してしまうと、変更前の`vm-name`で設定していたマシンは、Vagrantの管理対象から外れてしまうからです。

### 1-6. SSHログインの設定

これまでは以下のようにログインしてきましたが、

```
$ vagrant ssh mickey
```

このコマンドを実行するの制約として、Vagrantfileが保存されている場所に移動しなければならなかったり、Itamaeを使った設定がやりづらかったりするので、SSHで公開鍵認証できるように設定しておきます。

とはいっても簡単です。これだけです。

```bash
$ cd test-box # Vagrantfileがあるディレクトリ
$ vagrant ssh-config >> ~/.ssh
```

上記の設定が完了したら、SSHログインしてみましょう。

```bash
# mickeyマシンへのログイン
$ ssh mickey
[vagrant@mickey ~]$
[vagrant@mickey ~]$ exit

# mineyマシンへのログイン
$ ssh miney
[vagrant@miney ~]$
[vagrant@miney ~]$ exit
```

### 1-7. 仮想マシンのロールバックを可能にするsahara

ここまででも十分便利なのですが、Vagrantにsaharaというプラグインを入れると、仮想マシンの途中の状態を記憶しておいて、ロールバックすることが可能になります。

saharaをインストールしてみましょう。

```bash
$ vagrant plugin install sahara
Installing the 'sahara' plugin. This can take a few minutes...
Fetching: Platform-0.4.0.gem (100%)
Fetching: open4-1.3.4.gem (100%)
Fetching: popen4-0.1.2.gem (100%)
Fetching: sahara-0.0.17.gem (100%)
Installed the plugin 'sahara (0.0.17)'!
```

saharaの基本的なコマンドは以下のとおりです。  
必要に応じて使ってみてください。  

```bash
# sandboxモードを有効にする
$ vagrant sandbox on

# ロールバック
$ vagrant sandbox rollback

# コミット
$ vagrant sandbox commit

# sandboxモードの解除
$ vagrant sandbox off
```

長くなりましたね！Vagrantについてはここまでです！

## 2. Itamaeを使ったセットアップ

![img](img/itamae-logo.png)

Itamaeは一言でいうと、Cookpadが開発したサーバの構成管理ツールになります。

<u>[Itamae公式サイト]</u>  
https://github.com/itamae-kitchen/itamae

構成管理ツールには代表的なものとして他にもChef、Puppet、Ansibleなどがあるのですが、Rubyで記述が出来るという点と、何よりも、**覚えることが少なく気軽に使える**という点で優れています。

これからローカル環境にitamaeをインストールし、Vagrantで構築した仮想マシンに色々セットアップしていきます。

### 2-1. Itamaeのインストール

Itamaeをローカル環境にインストールしていきます。  
前提条件として、ローカル環境にRubyが必要なのでインストールしておいてください。

Itamaeのインストールは、これだけです。

```bash
$ gem install itamae
```

以下のコマンドが実行できればOKです。

```bash
$ itamae version
Itamae v1.9.11
```

### 2-2. Itamaeを使ってみる

Itamaeを使うために、レシピファイルと呼ばれる設定ファイルが必要になります。  
今回は`test-box`フォルダの中に`cookbooks`というフォルダを作り、その中にレシピファイルを作っていくことにしましょう。

以降はローカル環境での作業になるので、特に記述がない場合にはローカル環境で作業していると考えてください。

```bash
$ cd test-box
$ mkdir cookbooks
```

また、saharaでsandboxモードを有効化しておきましょう。  
なお、本章では前章で構築した仮想マシンmickeyを使ってレシピを適用してくこととします。

```bash
$ vagrant sandbox on mickey
[miney] Starting sandbox mode...
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
[mickey] Starting sandbox mode...
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
```

それでは、レシピファイルを作成し、編集していきます。

```
$ touch cookbooks/recipe.rb
```

**recipe.rb**

```ruby
package "vim" do
  action :install
end
```

このようにして、`vim`をインストールするためのコードを書いてみました。

書いたレシピをmickeyマシンに対して適用してみましょう。  
`itamae ssh -h [マシン名] [レシピファイル名]`として実行すればOKです。
ここで、オプションに`-n`をつけると、実行せずにどのような処理が実行されるかを確認できるので、事前に実行してみるとよいです。

```bash
$ itamae ssh -h mickey cookbooks/recipe.rb -n
 INFO : Starting Itamae...
 INFO : Recipe: /Users/nagakuray/Desktop/test-box/cookbooks/recipe.rb
 INFO :   package[vim] installed will change from 'false' to 'true'
```

いろいろ出力されますが、vimをインストールする、ということがわかるかと思います。  
確認したら`-n`オプションを外してレシピを実行しましょう。

```bash
$ itamae ssh -h mickey cookbooks/recipe.rb
 INFO : Starting Itamae...
 INFO : Recipe: /Users/nagakuray/Desktop/test-box/cookbooks/recipe.rb
 INFO :   package[vim] installed will change from 'false' to 'true'
```

実行が終わったら、mickeyサーバにログインして`vim`が起動するか確かめて見ましょう。

```bash
$ ssh mickey
[vagrant@mickey ~]$ vim
```

vimが起動できたと思います。  
これがItamaeの基本的な使い方になります。

ここまでで大事な点がひとつあります。  
こういった構成管理ツールは、**サーバのあるべき状態を記述している点に注意してください**。
レシピを再度実行しても、**実行するたびにvimがインストールされるわけではありません。**  
vimがインストールされていれば、既に状態を満たしているので、何もしません。

試しに再度同じレシピを実行してみます。

```bash
$ itamae ssh -h mickey cookbooks/recipe.rb
```

前回の実行よりも早く終わるはずです。  
既にインストールされていれば、なにもしない、一回実行するのと複数回実行するので、同じ結果が保証されることを難しい言葉で**冪等性**というので、用語として覚えておくとよいです。

### 2-3. リソースとアトリビュートについて

Itamaeの構文はシンプルです。  
`リソース`の名前を書いて、ブロックの中の`アトリビュート`とその値を設定していく構成になっています。  
まずは、用語だけ覚えておけばOKです。

```ruby
リソース "リソースに与える名前" do
  アトリビュート 値
  アトリビュート 値
  アトリビュート 値
end
```

先程のコードを再掲します。  
このコードの場合は、リソースが`package`、アトリビュートが`action`となっています。

```ruby
package "vim" do
  action :install
end
```

リソースの種類やアトリビュートは公式サイトを見ると、詳しく載っています。

<u>[Itamae公式サイト]</u>  
https://github.com/itamae-kitchen/itamae/wiki/Resources

以降は、リソースの使い方について見ていきますが、その前に全リソース共通のアトリビュートを説明しておきます。

 

| アトリビュート名| 説明 | 必須 | 型 |
|:-------------|:-----|:-----|:---|
| action | 実行するアクション | No | one of Symbol or Array |
| only_if | あるコマンドが成功した時のみに実行 | No | String |
| not_if | あるコマンドが失敗した時のみに実行 | No | String |
| user | 実行ユーザ | No | String |

あまり良くない例ですが、以下のコードを参考にしてみてください。

**cookbooks/recipe.rb**

```ruby
# 192.168.*.*のIPアドレスが有効になっていない場合に、networkサービスを再起動
service "network" do
  action [:restart,:enable] # actionを配列で指定
  user "root" # userを文字列で指定
  not_if "ip addr show | grep 192.168.*.*" # not_ifを文字列で指定
end

# firewalldサービスが起動している場合に、firewalldを停止する
execute "systemctl stop firewalld" do
  only_if "systemctl staus firewalld" # only_ifを文字列で指定
end
```

実行例です。慣れてもらうために、しつこいですが載せていきます。

```bash
$ itamae ssh -h mickey cookbooks/recipe.rb
```

それでは、リソースについて以降紹介していきます。  
すべてのリソース、アトリビュートは筆者の力では紹介しきれないので、筆者がよく使うリソースとアトリビュートについて紹介していきます。

### 2-4. package

packageリソースは、パッケージをインストール、削除ができます。

<u>**よく使うアトリビュート**</u>

| アトリビュート名| 説明 | 必須 | 型 |
|:-------------|:-----|:-----|:---|
| name | パッケージ名 | No | String |
| version | パッケージのバージョン | No | String |

<u>**アクションのデフォルト値**</u>

| アトリビュート名| 値 |
|:-------------|:-----|
| action | :install |


例になります。`cookbooks/recipe.rb`に追記して実行してみてください。

```ruby
# 基本的な書き方
package "install httpd" do
  name "httpd"
  version "2.4.6"
  action :install
end

# action :installは必須かつデフォルトなので、書かなくてもいい。
# versionを指定しない場合は、こういった書き方もできる。
package "mariadb"
```

### 2-5. service

serviceリソースは、サービスの起動や終了を定義します。

<u>**よく使うアトリビュート**</u>

| アトリビュート名| 説明 | 必須 | 型 |
|:-------------|:-----|:-----|:---|
| name | パッケージ名 | No | String |

<u>**アクションのデフォルト値**</u>

| アトリビュート名| 値 |
|:-------------|:-----|
| action | :nothing |

例になります。`cookbooks/recipe.rb`に追記して実行してみてください。

```ruby
service "mariadb" do
  action [:stop,:disable]
end

service "httpd" do
  action [:start,:enable]
end
```

### 2-6. groupリソース

groupリソースは、グループを作成します。

<u>**よく使うアトリビュート**</u>

| アトリビュート名| 説明 | 必須 | 型 |
|:-------------|:-----|:-----|:---|
| gid | グループID | No | Integer |
| groupname | ユーザ名 | No | String |


<u>**アクションのデフォルト値**</u>

| アトリビュート名| 値 |
|:-------------|:-----|
| action | :create |


例になります。`cookbooks/recipe.rb`に追記して実行してみてください。

```ruby
# 基本的な書き方
group "create unadon group" do
  gid 1234 # gidがない場合は、自動で作られる。
  groupname "unadon1"
  action :create
end

# action :createは必須かつデフォルトなので、書かなくてもいい。
group "unadon2" do
  groupname "unadon2"
end

# さらに、groupnameのデフォルト値はリソース名になるので書かなくてもいい。
group "unadon2"
```

### 2-7. userリソース

userリソースは、ユーザを作成します。

<u>**よく使うアトリビュート**</u>

| アトリビュート名| 説明 | 必須 | 型 |
|:-------------|:-----|:-----|:---|
| uid | ユーザID | No | Integer |
| gid | グループID | No | String |
| username | ユーザ名 | No | String |
| password | パスワード | No | Strings |
| home | 作成するユーザのホームディレクトリ | No | String |
| shell | ログインシェル | No | String |
| system_user | システムユーザか | No | true or false |

<u>**アクションのデフォルト値**</u>

| アトリビュート名| 値 |
|:-------------|:-----|
| action | :create |

ちなみに、ユーザのパスワードは平文で設定してもその通りにパスワードが設定されません。  
SHA512でハッシュ化する必要があります。`unix-crypt`というgemを使うと簡単です。

```
$ gem install unix-crypt
$ mkunixcrypt
Enter password: # パスワードを入力する 例：mypassword
Verify password:
$6$oVo8BJnYMQzX5RCn$OYabLLdW33eJRK8I49aDdH6qrjylNaIpWn0IxQo4J.e1LNHHfje8qyK666UTBmCXPfaS1QQo8536uAPKt4o810
```


例となります。`cookbooks/recipe.rb`に追記してみましょう。

```ruby
# 基本的な書き方
user "create kitty user" do
  gid 1234
  uid 1235
  username "kitty"
  password "$6$oVo8BJnYMQzX5RCn$OYabLLdW33eJRK8I49aDdH6qrjylNaIpWn0IxQo4J.e1LNHHfje8qyK666UTBmCXPfaS1QQo8536uAPKt4o810"
  action :create
end

# action :createは必須かつデフォルトなので、書かなくてもいい。
user "tiddy" do
  username "tiddy"
  password "$6$oVo8BJnYMQzX5RCn$OYabLLdW33eJRK8I49aDdH6qrjylNaIpWn0IxQo4J.e1LNHHfje8qyK666UTBmCXPfaS1QQo8536uAPKt4o810"
end

# usernameのデフォルト値はリソース名になるので、書かなくてもいい。
user "tiddy" do
  password "$6$oVo8BJnYMQzX5RCn$OYabLLdW33eJRK8I49aDdH6qrjylNaIpWn0IxQo4J.e1LNHHfje8qyK666UTBmCXPfaS1QQo8536uAPKt4o810"
end
```

### 2-8. directory

directoryリソースは、ディレクトリを作成します。

<u>**よく使うアトリビュート**</u>

| アトリビュート名| 説明 | 必須 | 型 |
|:-------------|:-----|:-----|:---|
| path | 作成するディレクトリのパス | No | String |
| mode | 権限 | No | String |
| owner | 所有者 | No | String |
| group | 所有グループ | No | String |

<u>**アクションのデフォルト値**</u>

| アトリビュート名| 値 |
|:-------------|:-----|
| action | :create |

例になります。`cookbooks/recipe.rb`に追記してみましょう。

```ruby
# 基本的な書き方
directory "make test directory" do
  path "/tmp/testdir"
  mode "755"
  owner "kitty"
  group "unadon1"
  action :create
end

# action :createは必須かつデフォルトなので、書かなくてもいい。
directory "/tmp/testdir2" do
  path "/tmp/testdir"
  mode "755"
  owner "kitty"
  group "unadon1"
end

# pathのデフォルト値はリソース名になるので、書かなくてもいい。
directory "/tmp/testdir2" do
  mode "755"
  owner "kitty"
  group "unadon1"
end

# mode, owner, groupを省略してこういった書き方もできる。
# その場合の権限は、所有者root、所有グループrootになる。
directory "/tmp/testdir3"
```

### 2-9. executeリソース

executeリソースは、シェルコマンドを実行します。

<u>**よく使うアトリビュート**</u>

| アトリビュート名| 説明 | 必須 | 型 |
|:-------------|:-----|:-----|:---|
| command | 実行するシェルコマンド | No | String |

<u>**アクションのデフォルト値**</u>

| アトリビュート名| 値 |
|:-------------|:-----|
| action | :run |

例になります。`cookbooks/recipe.rb`に追記してみましょう。

```ruby
# 基本的な書き方
execute "create an empty file" do
  command "touch /tmp/testdir/non_empty_file"
  not_if "test -e /tmp/testdir/non_empty_file"
  action :run
end

# action :runは必須かつデフォルトなので、書かなくてもいい。
execute "touch /tmp/testdir/non_empty_file2" do
  command "touch /tmp/testdir/non_empty_file2"
end

# commandのデフォルト値はリソース名になるので、書かなくてもいい。
execute "touch /tmp/testdir/non_empty_file3"
```

### 2-10. remote_file

remote_fileリソースは、ファイル転送を実行します。

<u>**よく使うアトリビュート**</u>

| アトリビュート名| 説明 | 必須 | 型 |
|:-------------|:-----|:-----|:---|
| owner | 所有者 | No | String |
| group | 所有グループ | No | String |
| mode | 権限 | No | String |
| path | 転送先の絶対ファイルパス名 | No | String |
| source | 転送元の相対ファイルパス名 | No | String |

<u>**アクションのデフォルト値**</u>

| アトリビュート名| 値 |
|:-------------|:-----|
| action | :create |

転送元のファイルですが、レシピファイルと同じ階層に`files`フォルダを作成しておき、`files`フォルダに転送元のファイルを保存しておく必要がありますので、作成しておきましょう。

```bash
$ mkdir cookbooks/files
$ echo "using remote_file resouce" > cookbooks/files/remote_file_test.txt
```

例になります。`cookbooks/recipe.rb`に追記してみましょう。

```ruby
# 基本的な書き方
remote_file "create an remote_file_test.txt" do
  source "files/remote_file_test.txt"
  path "/tmp/testdir/remote_file_test.txt"
  mode "755"
  owner "kitty"
  group "unadon1"
  action :create
end

# action :createは必須かつデフォルトなので、書かなくてもいい。
remote_file "create an remote_file_test.txt" do
  source "files/remote_file_test.txt"
  path "/tmp/testdir/remote_file_test.txt"
  mode "755"
  owner "kitty"
  group "unadon1"
end

# pathのデフォルト値はリソース名になるので、書かなくてもいい。
remote_file "/tmp/testdir/remote_file_test.txt" do
  source "files/remote_file_test.txt"
  mode "755"
  owner "kitty"
  group "unadon1"
end

# sourceは書いていない場合、転送元のfilesディレクトリを自動的に参照してくれる
# files/remote_file_test.txtが自動で設定される
remote_file "/tmp/testdir/remote_file_test.txt" do
  mode "755"
  owner "kitty"
  group "unadon1"
end
```

### 2-11. template

templateリソースは、用意したテンプレートファイル(erb)を転送します。  
remote_fileリソースと似ているのですが、テンプレートファイルに変数を引き渡すことができます。

<u>**よく使うアトリビュート**</u>

| アトリビュート名| 説明 | 必須 | 型 |
|:-------------|:-----|:-----|:---|
| owner | 所有者 | No | String |
| group | 所有グループ | No | String |
| mode | 権限 | No | String |
| path | 転送先の絶対ファイルパス名 | No | String |
| source | 転送元の相対ファイルパス名 | No | String |
| variables | テンプレートに渡すパラメータ| No | Hash |

<u>**アクションのデフォルト値**</u>

| アトリビュート名| 値 |
|:-------------|:-----|
| action | :create |

転送元のテンプレートファイルですが、レシピファイルと同じ階層に`templates`フォルダを作成しておき、`templates`フォルダに転送元のテンプレートファイルを保存しておく必要がありますので、作成しておきましょう。

```bash
$ mkdir cookbooks/templates
```

テンプレートファイルについてみてみましょう。  
ここでは、`sample_template.txt.erb`を用意します。  

テンプレートファイルに変数を埋め込む方法は3つほど用意されています。3つともよく使うので、覚えておくとよいでしょう。

* variablesアトリビュートを使う方法
* ホストインベントリを使う方法
* ノードアトリビュートを使う方法

**cookbooks/templates/sample_template.txt.erb**

```ruby
# variablesアトリビュートを使う
Hello, <%= @message %>

# ホストインベントリを使う
Server hostname is <%= node['hostname'] %>

# ノードアトリビュートを使う
Goodbye, <%= node[:hogehoge] %>
```

variablesアトリビュートを使う方法は、例で確認しましょう。

ホストインベントリは、Itamaeが定義してくれているパラメータです。以下を参考にしてください。`host_inventry`の部分を`node`に読み替えてください。

<u>[ホストインベントリ]</u>  
http://serverspec.org/host_inventory.html

ノードアトリビュートは、JSONファイル、もしくはYAMLファイルを作成し、ファイル内に変数を定義する方法です。  
YAMLで定義した場合は、こんな感じです。

**cookbooks/node.yml**

```
hogehoge: World!
```

これらを踏まえた上で、例を見ていきましょう。
`cookbooks/recipe.rb`に追記してみてください。

```ruby
# sourceを省略した書き方
# templatesフォルダのsample_template.txt.erbを自動的に参照する
template "/tmp/testdir/sample_template.txt" do
  variables message: "Ruby"
end
```

テンプレートファイル`sample_template.txt.erb`がノードアトリビュートを利用しているので、itamaeの実行引数に`-y`オプションを付けて`node.yml`を指定する必要があります。

```bash
$ itamae ssh -h mickey cookbooks/recipe.rb -y cookbooks/node.yml
```


### 2-12. gitリソース

gitリソースは、`git clone`を実行します。

<u>**よく使うアトリビュート**</u>

| アトリビュート名| 説明 | 必須 | 型 |　デフォルト値 |
|:-------------|:-----|:-----|:---|:----------|
| user | 実行するユーザ | No | 文字列 | なし |
| destination | クローン先のディレクトリ | No | 文字列 | リソースに与える名前 |
| repository | クローンするリポジトリ | Yes | 文字列 | なし |
| revision | リポジトリのリビジョン | no | 文字列 | なし |

<u>**アクションのデフォルト値**</u>

| アクション名| 説明 |
|:-------------|:-----|
| `:sync` | 同期 |

例になります。`recipe.rb`に追記してみましょう。

**recipe.rb**

```ruby
package "git"

# 基本的な書き方
git "git clone repotitory" do
  repository "https://github.com/48hands/ruby-study.git"
  destination "/tmp/ruby-study"
  action :sync
end

# action :createは必須かつデフォルトなので、書かなくてもいい。
# destinationのデフォルト値はリソース名になるので、書かなくてもいい。
git "/tmp/bootstrap" do
  repository "https://github.com/48hands/bootstrap.git"
end
```

ここまでで、よく使うであろうリソースとアトリビュートについて紹介してきました。  
これ以外にも公式ドキュメントには、いろいろありますので、目を通しておくと尚よいでしょう！

<u>[Itamae公式サイト]</u>  
https://github.com/itamae-kitchen/itamae/wiki/Resources


### 2-13. これまで学んだことを使ってみよう!

ItamaeのレシピファイルはRubyですので、配列を使ったり、繰り返しを使った書き方ももちろんできます。学んできたことを少し活用してみるとよいでしょう。  
以下は、ユーザを複数作成する場合のテクニックです。

**cookbooks/user_recipe.rb**

```ruby
users = %w(donald dazy aradin duffy)
users.each do |name|
 user name do
  password "$6$oVo8BJnYMQzX5RCn$OYabLLdW33eJRK8I49aDdH6qrjylNaIpWn0IxQo4J.e1LNHHfje8qyK666UTBmCXPfaS1QQo8536uAPKt4o810"
  home "/usr/local/#{name}"
 end
end
```

```bash
$ itamae ssh -h mickey cookbooks/user_recipe.rb
```


### 2-14. include_recipe

共通のレシピを作っておき、それを個別のレシピにインクルードして使いたいような場合があると思います。
そういった場合には、`include_recipe`を使います。  
例を紹介します。

共通のレシピです。

**cookbooks/common_recipe.rb**

```ruby
%w(vim git gcc).each do |name|
  package name
end
```

共通のレシピをインクルードするレシピです。

**cookbooks/dizney_recipe.rb**

```ruby
# 共通のレシピをインクルードする
include_recipe "./user_recipe.rb"
include_recipe "./common_recipe.rb"

directory "/tmp/dizney_work"
```

実行する場合は、こんな感じです。

```bash
$ itamae ssh -h mickey cookbokos/dizney_recipe.rb
```

### 2-15. 後始末

ここまでできたら、mickeyサーバへの変更をコミットしておきましょう。  
2-2.でvagrantのsandboxモードを有効化しているはずなので、コミットしておきましょう。

```
# コミットは以下のコマンドです。vagrant haltで停止してからcommitしましょう。
$ vagrant stop mickey
$ vagrant sandbox commit mickey
[mickey] Committing the virtual machine...
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
```

おつかれさまです。ここまでVagrant、Itamaeを使って、インフラをコード化してきましたね！  
次はいよいよ、インフラのテストコードにチャレンジです!  
もう少々お付き合いください。

## 3. Serverspec

![img](img/serverspec-logo.jpg)

Serverspecについて学んでいきましょう！

これ以降は、1.で構築した仮想マシン`aradin`を使っていきます。  
起動しているか確認しましょう。`running`になっていればOKです。

```bash
$ vagrant status aradin
Current machine states:

aradin                   running (virtualbox)
```

Serverspecとは何かについて簡単に説明した後、実際にテストコードを書いてみましょう。

### 3-1. Serverspecとは

ひとことでいうと、サーバの自動テストを実現するツールです。

ChefやItamae、Anbibleといったサーバの設定を自動で実行してくれるツールがありますが、同時にサーバの自動テストについても近年は注目されるようになってきています。  
サーバ構築後の確認をマニュアルを使って、コマンドを叩いて、目視で確認するのがこれまでは一般的でした。  
しかし、手作業での確認にはミスや抜け漏れが発生する可能性があります。そして、サーバの台数が増えてしまうと、それに伴い確認する手間は増えてしまいます。  
こういった深刻な課題を解決してくれるのが、サーバの自動テストツールであり、Serverspecであります。

ServerspecはRubyで実装されています。RubyやRuby向けのテストフレームワークであるRSpecの機能を活用して実装されています。
ここまで学んだRubyの知識がVagrantやItamaeと同様、Serverspecにも学んできたことが活かせるということです。

なお、公式サイトはこちらになります。

<u>[Serverspec公式サイト]</u>  
http://serverspec.org/

### 3-2. Serverspecのインストール

早速インストールしていきましょう。Rubyがインストールされていれば、コマンド一発です。

```bash
$ gem install serverspec
```

Serverspecがインストールされているか確認しましょう。

```bash
$ gem list | grep serverspec
serverspec (2.40.0, 2.38.0)
```

### 3-3. serverspec-initコマンドを使ったテストスクリプトの作成とテストスクリプトの実行

テスト用のフォルダを作っていきましょう。  
ここまでで、Vagrantfileやcookbooksをtest-boxというフォルダの中に作ってきたはずです。test-boxフォルダに移動しましょう。

```bash
$ cd test-box
$ ls
Vagrantfile   cookbooks   setting.yml
```

ここにServerspec用のフォルダを作成し、色々なファイルを自動で作ってくれる`serverspec-init`コマンドを実行します。

```bash
$ serverspec-init
Select OS type:

  1) UN*X
  2) Windows

Select number: 1

Select a backend type:

  1) SSH
  2) Exec (local)

Select number: 1

Vagrant instance y/n: n
Input target host name: aradin
 + spec/
 + spec/aradin/
 + spec/aradin/sample_spec.rb
 + spec/spec_helper.rb
 + Rakefile
 + .rspec
 $
```

まずは、どのOSが対象ですか、と聞かれるのですが、今回は`1`のUNIX系を選んでください。  
aradinマシンにSSH接続するので、こちらも`1`を選択してください。  
Vagrantの特有の設定が必要か聞かれるのですが、今回は使わないので、`n`を選択してください。  
ターゲットの`host name`は、SSHで接続できる名前なので、今回は`aradin`にします。

ちなみに、SSHでの接続ですが、以下の事前設定が必要です。  
今回は、Vagrant設定時に上記に対応していますので、特に説明しません。

 - 公開鍵認証方式で対象とするマシンにログインできるようにしておく
 - ログインに使用するユーザーがsudoコマンドでroot権限を取得できるようにしておく


serverspec-initコマンドを実行したフォルダ内に「Rakefile」というファイルと「spec」ディレクトリが作成され、さらにspecファイルが「spec/aradin」フォルダ以下に作成されていますね。
それぞれ、以下の役割をもっています。

  * Rakefile  
  rakeコマンドを使ってテストを実行するためのファイル
  * spec/spec_helper.rb  
  テストを実行する際のテストの設定が記述されているファイル
  * spec/aradin/sample_spec.rb  
  テストスクリプト本体。デフォルトでWebサーバのテストのためのサンプルが記述されている。

では、この状態で一度テストスクリプトを実行してみましょう!  
aradinマシンには、何も設定していないので、テストは失敗するはずです。  
実行は簡単です。`Rakefile`があるフォルダで`rake`コマンドを一発打つだけです。  
以下のような結果が表示されればOKです。

```bash
$ rake

Package "httpd"
  should be installed (FAILED - 1)

Service "httpd"
  should be enabled (FAILED - 2)
  should be running (FAILED - 3)

Port "80"
  should be listening (FAILED - 4)

Failures:

  1) Package "httpd" should be installed
     On host `aradin'
     Failure/Error: it { should be_installed }
       expected Package "httpd" to be installed
       sudo -p 'Password: ' /bin/sh -c rpm\ -q\ httpd
       package httpd is not installed

     # ./spec/aradin/sample_spec.rb:4:in `block (2 levels) in <top (required)>'

  2) Service "httpd" should be enabled
     On host `miney'
     Failure/Error: it { should be_enabled }
       expected Service "httpd" to be enabled
       sudo -p 'Password: ' /bin/sh -c systemctl\ --quiet\ is-enabled\ httpd

     # ./spec/aradin/sample_spec.rb:12:in `block (2 levels) in <top (required)>'

  3) Service "httpd" should be running
     On host `aradin'
     Failure/Error: it { should be_running }
       expected Service "httpd" to be running
       sudo -p 'Password: ' /bin/sh -c systemctl\ is-active\ httpd
       unknown

     # ./spec/aradin/sample_spec.rb:13:in `block (2 levels) in <top (required)>'

  4) Port "80" should be listening
     On host `aradin'
     Failure/Error: it { should be_listening }
       expected Port "80" to be listening
       sudo -p 'Password: ' /bin/sh -c ss\ -tunl\ \|\ grep\ --\ :80\\\

     # ./spec/aradin/sample_spec.rb:27:in `block (2 levels) in <top (required)>'

Finished in 0.21856 seconds (files took 0.93243 seconds to load)
4 examples, 4 failures

Failed examples:

rspec ./spec/aradin/sample_spec.rb:4 # Package "httpd" should be installed
rspec ./spec/aradin/sample_spec.rb:12 # Service "httpd" should be enabled
rspec ./spec/aradin/sample_spec.rb:13 # Service "httpd" should be running
rspec ./spec/aradin/sample_spec.rb:27 # Port "80" should be listening
```

この部分をみればわかるのですが、テストケース4つ中4つとも失敗しています。

```bash
Finished in 0.21856 seconds (files took 0.93243 seconds to load)
4 examples, 4 failures
```

テストスクリプトファイルの説明無しでいきなり実行したのですが、テストスクリプトファイル`spec/miney/sample_spec.rb`は、以下のようになっています。

**spec/miney/sample_spec.rb**

```ruby
require 'spec_helper'

describe package('httpd'), :if => os[:family] == 'redhat' do
  it { should be_installed }
end

describe package('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_installed }
end

describe service('httpd'), :if => os[:family] == 'redhat' do
  it { should be_enabled }
  it { should be_running }
end

describe service('apache2'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled }
  it { should be_running }
end

describe service('org.apache.httpd'), :if => os[:family] == 'darwin' do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end
```

今回テスト対象としているaradinマシンは、CentOSなので、OSはRedHatに相当します。  
そのため、上記のテストスクリプトは、実際には以下となります。

**spec/miney/sample_spec.rb**

```ruby
# spec/spec_helper.rbを取り込む
require 'spec_helper'

# httpdパッケージに関するテスト
describe package('httpd'), :if => os[:family] == 'redhat' do
  # パッケージがインストールされているか確認する。
  it { should be_installed }
end

# httpdサービスに関するテスト
describe service('httpd'), :if => os[:family] == 'redhat' do
  # サービスが有効か確認する。
  it { should be_enabled }
  # サービスが起動しているか確認する。
  it { should be_running }
end

# 80番ポートに関するテスト
describe port(80) do
  # ポートが待受け状態になっているか確認する。
  it { should be_listening }
end
```

スクリプトの基本構文ですが、以下のようになります。

```ruby
describe リソースタイプ(テスト対象) do
  テスト条件
end
```

- リソースタイプでは、どのようなリソースに対してテストを実行するか指定します。  
用意されているリソース一覧は、公式ページを参考にしてください。  
http://serverspec.org/resource_types.html 
- テスト対象には、対象とするリソースを指定します。`package('httpd')`の場合はhttpdに関するテストを実行します。
- テスト条件は、対象とするリソースの状態を指定するものです。次のような書式で記述します。
  ```
  it { should 条件 }
  its(対象) { should 条件 }
  ```
  たとえば、packageリソースに対して次のように記述します。
  ```
  it { should be_installed}
  ```
  また、特定のファイルにマッチするテキストの有無を確認する場合、次のように`its`を使って表現できます。
  ```ruby
  describe file('/etc/httpd/conf/httpd.conf') do
    its(:content) { should match /ServerName localhost/ }
  end
  ```
  この、`{should 条件}`の「条件」部分を**マッチャー**といいますので覚えておいてください。`be_installed`、`be_running`の部分がマッチャーです。


 先に出てきた`spec/miney/sample_spec.rb`のテストケースが成功するように、Itamaeのレシピファイルを作成しましょう。

 **cookbooks/httpd_recipe.rb**

 ```ruby
package "httpd"

service "httpd" do
  action [:start,:enabled]
end
```

レシピの適用です。思い出してみましょう。

```bash
$ itamae ssh -h aradin cookbooks/httpd_recipe.rb
 INFO : Starting Itamae...
 INFO : Recipe: /Users/nagakuray/Desktop/hogehoge/cookbooks/httpd_recipe.rb
 INFO :   service[httpd] enabled will change from 'false' to 'true'
```

レシピを適用後、再度`rake`コマンドでテストスクリプトを実行してみましょう。

```bash
$ rake
Package "httpd"
  should be installed

Service "httpd"
  should be enabled
  should be running

Port "80"
  should be listening

Finished in 0.13634 seconds (files took 1.04 seconds to load)
4 examples, 0 failures
```

今度は、テストに合格しましたね！

### 3-4. よく使うテストの書き方

最後にテストコードのユースケースを紹介していきます。

あくまでもよく使いそうなテストコードの書き方ですので、これ以上は公式サイトを確認してください。とてもよく充実しています。

#### 3-4-1. インストール系

* <u>**複数のパッケージのインストール確認**</u>

  ```ruby
  %w("git vim httpd").each do |name|
    describe package(name) do
      it { should be_insalled }
    end
  end
  ```

* <u>**指定バージョンのパッケージのインストール確認**</u>

  ```ruby
  describe package("httpd") do
    it { should be_installed.with_version("2.4.6") }
  end
  ```

* <u>**gemやpipとして指定のバージョンのパッケージのインストール確認**</u>

  ```ruby
  describe package('jekyll') do
    it { should be_installed.by('gem').with_version('0.12.1') }
  end

  describe package('requests') do
    it { should be_installed.by('pip').with_version('2.18.1') }
  end
  ```

#### 3-4-2. コマンドによる確認

* <u>**標準出力からマッチする文字列を確認する**</u>

  ```ruby
  describe command("httpd -v") do
    its(:stdout) { should match /Apache\/2\.4\.6/}
  end
  ```

* <u>**コマンドの戻り値から確認する**</u>

  ```ruby
  describe command("ruby -v") do
    its(:exit_status) { should eq 127}
  end
  ```

* <u>**sudoでコマンドを実行しない**</u>

  ```ruby
  describe command("ruby -v") do
    let(:disable_sudo) { true }
    its(:exit_status) { should eq 127 }
  end
  ```

#### 3-4-3. サービスの起動確認

* <u>**サービスの自動起動設定と起動状態の確認**</u>

  ```ruby
  describe service("httpd") do
    it { should be_enabled }
    it { should be_running }
  end
  ```

* <u>**指定のポートの受付状態確認**</u>

  ```ruby
  describe port(80) do
    it { should be_listnening}
  end
  ```

* <u>**curlでのHTTPリクエストの結果確認**</u>

  ```ruby
  describe command("curl -I http://localhost -o /dev/null -w "%{http_code}\n" -s") do
    its(:stdout) { should match /^403$/ }
  end
  ```
  curlコマンドのオプションについて少し補足しておきます。  
  `-I`でレスポンスヘッダだけ取得するようにしています。`-w`(write out)で`http_code`を指定しています。`-o`(output)で`/dev/null`にhttp_code以外を捨てています。`-s`(silent)で進捗を表示しないようにしています。

#### 3-4-4. ユーザ、グループ

* <u>**グループが存在するか確認する**</u>

  ```ruby
  describe group("vagrant") do
    it { should  exist}
  end
  ```

* <u>**ユーザがグループに存在するか確認する**</u>

  ```ruby
  describe user("vagrant") do
    it { should belong_to_group "vagrant" }
  end
  ```

#### 3-4-5. ファイルの確認

* <u>**ファイルの中身に指定のテキストがあるか確認する**</u>

  ```ruby
  describe file("/etc/hosts") do 
    its(:content) { should match /127\.0\.0\.1   localhost/}
  end
  ```
* <u>**ファイルに読み込み、書き込みの権限、実行権限が特定のユーザにあるか確認する**</u>

  ```ruby
  %w(/var/log/httpd/access_log /var/log/httpd/error_log).each do |name|
    describe file(name) do
      # rootユーザに読み込み権限があるか確認
      it { should be_readable.by_user("root")}
      # rootユーザに書き込み権限があるか確認
      it { should be_writable.by_user("root")}
    end
  end

  describe file("/bin/bash") do
    # rootユーザに実行権限があるか確認
    it { should be_executable.by_user("root") }
  end
  ```

* <u>**ディレクトリのオーナーとパーミッションを確認する**</u>

  ```ruby
  describe file("/home/vagrant/.ssh") do
    it { should be_directory }
    it { should be_owned_by("vagrant") }
    it { should be_grouped_into("vagrant") }
    it { should be_mode "700" }
  end
  ```

#### 3-4-6. ネットワーク系の確認

* <u>**特定のポート番号で実際に接続できるか確認する**</u>

  ```ruby
  describe host("192.168.10.11") do
    # ping
    it { should be_reachable }
    # tcp port 22
    it { should be_reachable.with( :port => 22, :proto => "tcp") }
  end
  ```

* <u>**特定のホストが指定したIPアドレスで疎通可能か確認する**</u>

  ```ruby
  describe host("mickey") do
    its(:ipaddress) { should eq "192.168.10.11"}
  end
  ```
* <u>**名前解決できるか確認する**</u>

  ```ruby
  describe host("mickey") do
    # /etc/hostsで名前解決可能か調べる
    it { should be_resolvable.by("hosts") }
  end
  ```

#### 3-4-7. ホストインベントリを使った確認

Itamaeで利用していたホストインベントリが利用可能です。  
というより、Serverspecのホストインベントリが本家です。

利用可能なホストインベントリは、こちらを参考にしてください。

<u>[ホストインベントリ]</u>  
http://serverspec.org/host_inventory.html

ホストインベントリは、動的にテスト対象のホスト名を取得したり、リソース情報を取得したりできる機能でしたね。  
`host_inventory`で利用できます。

```ruby
# テスト対象マシンのホスト名を取得
host = host_inventory["hostname"]

describe file("/etc/hosts") do
  its(:content) { should match /#{host}/ }
end
```

### 3-5. テストスクリプトの共有方法

複数のマシンで共通するテストスクリプトを使う方法です。  
aradinマシンとmickeyマシンで共通のテストスクリプトを使う場合を紹介します。

#### 3-5-1. 現状の問題点

現在`spec`フォルダ配下は、以下のような構成になっていると思います。

<u>現在のspecフォルダの構成</u>

```bash
Rakefile
spec
├── aradin
│   └── sample_spec.rb
└── spec_helper.rb
```

さらにmickeyマシン用のテストスクリプトを`serverspec-init`コマンドで作るとこのようになります。

```bash
Rakefile
spec
├── aradin
│   └── sample_spec.rb
├── mickey
│   └── sample_spec.rb
└── spec_helper.rb
```

しかし、上記のフォルダ構成は、テストスクリプトをマシン単位で書かざるを得ない構成となっています。  
たとえば、aradinマシンとmickeyマシンでhttpdのインストール確認、サービス起動確認をする場合には、テストスクリプトを`spec/aradin/sample_spec.rb`と`spec/mickey/sample_spec.rb`に冗長に書くことになってしまいます。

#### 3-5-2. テストスクリプトの共有化

テストスクリプトをロール(役割)ごとに書き直してみましょう。  
フォルダ構成を以下のようにします。

```bash
Rakefile
properties.yml
spec
├-- base
│   └-- users_and_groups_spec.rb
├-- web
│   └-- httpd_spec.rb
└-- spec_helper.rb
```

**properties.yml**

このファイルを新規に作成して、マシンごとにロールを定義しましょう。  
今回は、`Yaml`形式で定義します。

```bash
aradin:
  :roles:
    - base
    - web
mickey:
  :roles:
    - base
```

**Rakefile**

`Rakefile`の定義を以下のように変更します。

`properties.yml`から取得した各マシン名を`TARGET_HOST`という環境変数に格納し、「`spec/指定した役割のフォルダ/*_spec.rb`」のテストスクリプトファイルを実行するようにタスクを定義しています。

```ruby
require 'rake'
require 'rspec/core/rake_task'
require 'yaml'

properties = YAML.load_file("properties.yml")

desc "Run serverspec to all hosts"
task :spec => 'serverspec:all'
 
namespace :serverspec do
  task :all => properties.keys.map {|key| 'serverspec:' + key.split('.')[0] }
  properties.keys.each do |key|
    desc "Run serverspec to #{key}"
    RSpec::Core::RakeTask.new(key.split('.')[0].to_sym) do |t|
      ENV['TARGET_HOST'] = key
      t.pattern = 'spec/{' + properties[key][:roles].join(',') + '}/*_spec.rb'
    end
  end
end
```

上記の`Rakefile`の設定を実施すると、各マシンに対して実行するテストスクリプトファイルが決まります。  
`rake -T`のオプション付きコマンドでrakeのタスク一覧を確認すると、以下のようになります。

```bash
$ rake -T
rake serverspec:aradin  # Run serverspec to aradin
rake serverspec:mickey  # Run serverspec to mickey
rake spec               # Run serverspec to all hosts
```

**spec/base/users_and_groups_spec.rb**

```ruby
require 'spec_helper'

describe user("vagrant") do
  it { should exist }
end

describe group("vagrant") do
  it { should exist }
end

describe user("vagrant") do
  it { should belong_to_group "vagrant" }
end
```

**spec/web/httpd_spec.rb**

```ruby
require 'spec_helper'

describe package("httpd") do
  it { should be_installed}
end
```

準備が整ったら、実行してみましょう。

* aradinマシンのみテストする場合
  ```bash
  $ rake serverspec:aradin
  ...
  Finished in 0.73191 seconds (files took 0.38963 seconds to load)
  4 examples, 0 failures
  ```

* mickeyマシンのみテストする場合
  ```bash
  $ rake serverspec:mickey
  ...
  Finished in 0.67969 seconds (files took 0.40637 seconds to load)
  3 examples, 0 failures
  ```

* すべてのマシンをテストする場合
  ```bash
  $ rake spec
  ...
  Finished in 0.76601 seconds (files took 0.40135 seconds to load)
  4 examples, 0 failures
  ...
  ...
  Finished in 0.43339 seconds (files took 0.42011 seconds to load)
  3 examples, 0 failures
  ```

## 4. まとめ

Serverspecについては、このくらいにしておきます。  
随分長くなってしまいましたね。おつかれさまです。

ここまででRubyをベースにインフラのコード化(Infrastructure as Code)を学んできました。  
Rubyを学んできたので少しは簡単に感じられたのではないでしょうか。  
ぜひプロジェクトに活用していきましょう。


## 5. 演習問題

演習問題を復習用に用意しました。  
順にこなしていきましょう。

### 演習問題1

新しくプロジェクトを作って仮想マシンを`Vagrantfile`に定義してみましょう。  
プロジェクト名は`spark-box`としてください。  
仮想マシン接続においては、ローカル端末から公開鍵認証方式でパスワードなしでSSH接続できるようにしておいてください。

**<u>仮想マシン</u>**
* 利用するbox: centos/7
* マシン名: nobita
* ホスト名: nobita
* CPU: 2
* メモリ: 1500MB
* IPアドレス: 192.168.20.10

### 演習問題2

Itamaeを使って、仮想マシン`nobita`にsparkをインストールしてみましょう。  
プロジェクト`spark-box`フォルダ内に`cookbooks/spark_recipe.rb`レシピを作成しましょう。

以下、ヒントのみ記載します。

**cookbooks/spark_recipe.rb**

```ruby
# Javaをインストールする。
# java-1.8.0-openjdk, java-1.8.0-openjdk-devel
#
# package resourceを使ってください。


# Apache Sparkをダウンロードする
# https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz
# spark-2.2.0-bin-hadoop2.7.tgzが存在していれば、ダウンロードしないようにする。
#
# execute resourceを使うといいでしょう。not_ifかonly_ifも使ってください。



# /usr/local/lib配下にspark-2.2.0-bin-hadoop2.7.tgzを解凍する。
# /usr/local/lib/spark-2.2.0-bin-hadoop2.7が存在している場合には、再解凍しないようにする。
#
# execute resourceを使うといいでしょう。not_ifかonly_ifも使ってください。



# シンボリックリンクを作成する。
# /usr/local/lib/sparkで/usr/local/lib/spark-2.2.0-bin-hadoop2.7にアクセスできるようにする。
#
# link resourceを使います。
# https://github.com/itamae-kitchen/itamae/wiki/link-resource



# spark用の環境変数ファイルを追加する。
# /etc/profile.d配下にspark.shを追加する。
# spark.shの中身は、以下の通り。
# export SPARK_HOME=/usr/local/lib/spark
# export PATH=$SPARK_HOME/bin:$PATH
# remote_file resourceかtemplate resourceを使うといいでしょう。

```

Itamaeレシピ適用後に以下のコマンドを実行してみましょう。  
円周率が計算できていれば成功です。

```
$ spark-submit --class org.apache.spark.examples.SparkPi --master local[2] $SPARK_HOME/examples/jars/spark-examples_2.11-2.2.0.jar 100
...
Pi is roughly 3.1413183141318313
...
```

余力があったら、Serverspecを使ってテストも書いてみましょう。
