
## 0. はじめに

今回は、これまでに紹介できなかった内容を補足の意味も込めて紹介します。  
いずれもRubyの学習において、とても大事なトピックですのできちんと理解できると中級者に近づけるでしょう。


## 1. ポリモーフィズムとダックタイピング

### 1-1. ポリモーフィズム

同じ名前のメソッドが複数のオブジェクトに属し、異なる結果が得られることをオブジェクト指向の用語で**ポリモーフィズム(多相性、または多態性)といいます。**  

オブジェクト指向言語の一般的な用語ですので、Rubyであっても、Javaなどと意味に差はありません。

以下の`to_s`メソッドの例がわかりやすいでしょう。

**polymorphism.rb**

```ruby
obj = Object.new
str = "Hello"
num = 1
hash = {name: "nagakuray", bloodType: "A"}

p obj.to_s
p str.to_s
p num.to_s
p hash.to_s
```

実行例です。

```bash
$ ruby polymorphism.rb
"#<Object:0x007ff722056100>"
"Hello"
"1"
"{:name=>\"nagakuray\", :bloodType=>\"A\"}"
```

ObjectとStringとFixnumとHashの各オブジェクトに対して、`to_s`メソッドを呼んでいます。それぞれで違う形式データを返していることがわかります。  
いずれも、**データを表示可能な形式で文字列化する**という意味の同じ名前のメソッドですが、**実際の文字列を作る手順は、各クラスのインスタンスメソッドで定義が異なります。**


### 1-2. ダックタイピング
ダックタイピング(Duck Typing)は、ポリモーフィズムを積極的に活用した考え方です。語源は、<u>「アヒルのように歩きアヒルのように鳴くものはアヒルに違いない(たとえ実際にはロボットだろうが、鴨だろうが)」</u>という格言からきています。 

**あるインスタンスのクラスが何であろうと、必要なメソッドに応答さえ出来れば処理を実行できる**という考え方です。

具体例を見てみるとイメージが付きやすいでしょう。  
「文字列が要素の配列から要素を取り出して、その要素に含まれるアルファベットを大文字にして返す」というメソッドの実装です。


```ruby
def fetch_and_upcase(data, index)
  str = data[index]
  str.upcase if str
end

data = ["josuke","jotaro","dio"]
p fetch_and_upcase(data, 1) # => "JOTARO"
```

上の例では`data`は配列オブジェクトですが、この`fetch_and_upcase`メソッドはハッシュオブジェクトにも対応しています。

```ruby
data = {0 => "josuke", 1 => "jotaro", 2 => "dio"}
p fetch_and_upcase(data, 1) # => "JOTARO"
```

さらには文字列オブジェクトにも対応しています。

```ruby
data = "dio"
p fetch_and_upcase(data,1) # => "I"
```

なぜなら、`fetch_and_upcase`メソッドが引数として渡されるオブジェクトに以下を期待しているからです。

* `data[index]`という形式で要素の取得が可能であること
* 取得できた要素オブジェクトが`upcase`メソッドを呼び出し可能であること

こういったダップタイピングができるのは、動的型付けが可能であるからです。  
Javaなどの静的型付け言語の場合は、メソッドの定義に型を定義する必要がありますが、Rubyのような動的型付け言語は実行時にはじめて型が決まるため、このようなことが可能になっています。

## 2. self、特異メソッド、特異クラスの補足

### 2-1. 現在のオブジェクトを表すself

Rubyでコードを記述すると、**つねにselfが存在しています。**
しかし、selfを普段意識することはあまりないです。

「self」は、Rubyに組み込まれている読み取り専用の変数です。
インスタンス変数にアクセスする場合や、メソッドを呼び出す場合にはselfが重要になっています。

selfの理解は、Rubyのメタプログラミング(コードを記述するためのコード)を理解する上で重要な要素のひとつになります。

#### 2-1-1. Rubyのインタプリタを開いたときのself

pryやirbを起動し、selfについて確認してみましょう。

```ruby
[1] pry(main)> self
=> main
[2] pry(main)> self.class
=> Object
```

実行結果より、現在のオブジェクトは`main`であり、`self`は`Object`クラスのオブジェクトであるということを示しています。

#### 2-1-2. selfを確認する

簡単なクラスを作成し、selfにどのようなオブジェクトが入っているかを確認してみましょう。

**self_confirm.rb**

```ruby
class Cat
  puts "(1) self: #{self}, self.class: #{self.class}"

  def walk
    puts "(2) self: #{self}, self.class: #{self.class}"
  end

end

puts "(3) self: #{self}, self.class: #{self.class}"

def run
  puts "(4) self: #{self}, self.class: #{self.class}"
end

Cat.new.walk
run
```

(1)のクラス定義では、selfは、**Catクラス**を示し、  
(2)のインスタンスメソッド内では、**Catクラスのインスタンス**  
(3)、(4)のトップレベルでは、**mainオブジェクト**を示していることがわかると思います。

```bash
$ ruby self.confirm.rb
(1) self: Cat, self.class: Class
(3) self: main, self.class: Object
(2) self: #<Cat:0x007ffb7e8c8850>, self.class: Cat
(4) self: main, self.class: Object
```

#### 2-1-3. 暗黙的なself

ここまでの例で、`self`が確かに存在し、コードの場所によって指し示すものが変わることが確認できました。

Rubyでは、以下のようにselfを省略できます。  
selfを省略した場合は、暗黙的にselfがレシーバになっています。  
下記の2つのコードは実行結果は同じです。

<u>**selfを省略した場合**</u>

```ruby
class User
  def initialize(name)
    @name = name
  end

  def get_name
    @name
  end

  def print_name
    puts "My name is #{get_name}"
  end

end
```


**selfを明示的に記述した場合**

```ruby
class User
  def initialize(name)
    @name = name
  end

  def get_name
    @name
  end

  def print_name
    # selfを明示的に記述
    puts "My name is #{self.get_name}"
  end

end
```

`self`への理解があれば、後述する`instance_eval`メソッドや、`class_eval`メソッドの理解に役立ちます。

#### 2-1-4. selfに変更を加えることのできるinstance_evalメソッド

`instance_eval`メソッドを使うと、`self`に変更を加えることができます。
これまでの内容では、attr_accessorなどのメソッドを使って、インスタンス変数、メソッドを制御してきました。

おさらいも兼ねてコードを以下に記載します。

```ruby
class User
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def greeting
    "Hello, #{@name}"
  end
end

user = User.new("Haenako")
puts user.greeting

user.name = "Taro"
puts user.greeting
```

`instance_eval`を使ったコードは以下のようになります。

```ruby
class User

  def initialize(name)
    @name = name
  end

end

# instance_evalでuserオブジェクトのインスタンス変数@nameを上書き
user.instance_eval{@name = "Taro"}

# instance_evalでuserオブジェクトのインスタンスメソッドにgreetingメソッドを定義
user.instance_eval do
  def greeting
    "Hello, #{@name}"
  end
end

# userオブジェクトに対してgreetingメソッドが使える
puts user.greeting # => "Hello, Taro"

# instance_evalは、あくまでもselfはuserオブジェクトがであるため、greetingはuserオブジェクトのみでしか利用できない
user2 = User.new("Ponta")
user2.greeting # => NoMethodError: undefined method `greetong'
```

`instance_eval`を使うと、簡単にオブジェクトのカプセル化を壊すことができます。  
このようなことがRubyでは簡単にできてしまうので、こういうことが出来る、ということだけ覚えておいてください。

#### 2-1-5. selfの変更とカレントクラスの定義変更ができるclass_evalメソッド

`instance_eval`メソッドは、`self`に対しての変更が対象でしたが、`class_eval`メソッドを使うと、**selfの変更に加えてクラスの定義を外から変更することができます。**

```ruby
class User
  def initialize(name)
    @name = name
  end

  def hello
    "Hello, #{@name}"
  end
end

# class_evalでUserクラスにgoodbyeメソッドを定義
User.class_eval do
  def goodbye
    "Goodbye #{@name}"
  end
end

# Userクラスを定義変更しているので、Userクラスから生成されたどのオブジェクトからでもgoodbyeメソッドを呼び出し可能
user = User.new("Taro")
user2 = User.new("Hanako")
puts user.goodbye # => "Hello, Taro!"
puts user2.goodbye # => "Hello, Hanako!"

puts user.hello
```


### 2-1-6. コードを生成するコードの例

以下は動的にクラス、メソッドを定義して実行した例です。  
`Dog`クラス、`Bird`クラス、`Cat`クラスにそれぞれ、`dog_roar`メソッド、`bird_roar`メソッド、`cat_roar`メソッドを定義しています。

Rubyでは、このようにメソッドを生成するメソッドなどを柔軟に定義したりとメタプログラミングが可能になっています。  
そしてこれを応用したのが、DSLであったり、Railsフレームワークであったりします。

**dynamic_define.rb**

```ruby
h = {Dog: "WanWan", Bird: "ChunChun", Cat: "NyahNyah"}

# クラスとインスタンスメソッドを動的に定義する
h.each do |class_name, roar|
  # クラス定義の定数を生成
  Object.const_set(class_name, Class.new)

  # クラス定義にインスタンスメソッドを定義
  Object.const_get(class_name).class_eval do
    # define_methodでメソッドを生成
    define_method("#{class_name.downcase}_roar") do
      puts "* #{class_name}'s roar is #{roar}."
    end
  end
end

# クラス定義とメソッドが動的に生成されているため、実行できる
Dog.new.dog_roar
Bird.new.bird_roar
Cat.new.cat_roar

# 上記3つのコードは、sendメソッドでも実行できる
puts "\nsendメソッド実行例-----------"
h.each_key do |class_name|
  obj = Object.const_get(class_name).new
  # sendメソッドで実行
  obj.send("#{class_name.downcase}_roar")
end
```

実行結果は、以下の通りです。

```bash
* Dog's roar is WanWan.
* Bird's roar is ChunChun.
* Cat's roar is NyahNyah.

sendメソッド実行例-----------
* Dog's roar is WanWan.
* Bird's roar is ChunChun.
* Cat's roar is NyahNyah.
```

### 2-2. オブジェクト固有のメソッド「特異メソッド」

Rubyでは、特定のオブジェクトのみ有効な、オブジェクト固有のメソッドを定義できます。  
通常は、あるクラスのオブジェクトは、クラスに定義されているメソッドしか利用できません。  
しかし、特異メソッドという仕組みを使うことによって、**オブジェクトに対してメソッドを追加定義できます。**

特異メソッドの例を以下に示します。
特異メソッドは以下の形式で定義します。

```ruby
def オブジェクト名.メソッド名
 (処理)
end
```

早速例を見てみましょう。

```ruby
bananas = []
grapes = []

def bananas.append_banana
  # 特異メソッドの定義中でのselfはbananasになる
  self << "banana"
end

5.times {bananas.append_banana}
p bananas

# grapesに対してメソッドは追加定義されていないため、以下のコードはエラーになる
# 5.times {grapes.append_banana}
```

`instance_eval`、`class_eval`、`特異メソッド`とオブジェクトに対してメソッドを追加する方法を紹介しましたが、本勉強会のRails学習では、これらを使う機会はないので忘れてもらって構いません。  
ただ、Rubyを本格的に勉強したり、DSLやメタプログラミングを実装する場合には、これらは登場しますので、頭の片隅においておきましょう。

### 2-3. 特異クラス

特異クラスは、**指定したオブジェクトのみで有効なクラス**です。  
例えば、既存のクラスからオブジェクトを生成した後、そのオブジェクトだけにちょっとした機能を追加する場合です。  
つまり、**継承をして新しいクラスを定義するほどには大げさでない場合**に、特異クラスを利用して、機能を追加します。

特異クラスは、以下のように定義されます。

```ruby
class << オブジェクト
  (メソッド、定数定義など)
end
```

`Fruits`クラスから生成されたオブジェクトに対して、特異クラスを定義した例です。

```ruby
class Fruits
end

fruits1 = Fruits.new
fruits2 = Fruits.new

# fruits1のみに機能を追加するため、特異クラスを定義
class << fruits1
  def colors
    [:black, :brown, :white, :mixed]
  end
end

# fruits1のみがcolorsメソッドを利用できる
p fruits1.colors

# fruits2ではcolorsメソッドが定義されていないため、利用できない。
p fruits2.colors
```

また、`self`もオブジェクトなので、以下のような`class << self`〜`end`で囲まれたクラスも特異クラスです。

以下の位置で定義されている`self`は、`Fruits`クラスオブジェクトを指すので、`class << self`〜`end`の間で定義されているメソッドは、`def self.colors`であり、読み替えると`def Fruits.colors`のようになります。つまり、クラスメソッドになります。

```ruby
class Fruits
  # この部分が特異クラス
  class << self
    # colorsはクラスメソッド
    def colors
      [:black, :brown, :white, :mixed]
    end
    # tasteもクラスメソッド
    def taste
      ["sweet", "spicy", "jucy"]
    end
  end
end

p Fruits.colors # => [:black, :brown, :white, :mixed]
p Fruits.taste # => ["sweet", "spicy", "jucy"]
```

上記のコードは以下のように書いても同じです。  
クラス定義中に`self.メソッド名`の形式で定義すると、クラスメソッドになるということを以前に紹介したと思います。


```ruby
class Fruits
  def self.colors
    [:black, :brown, :white, :mixed]
  end

  def self.taste
    ["sweet", "spicy", "jucy"]
  end
end
```

どちらの形式で記述しても同じですが、複数のクラスメソッドを定義する場合は、`class << self`〜`end`で定義することが多いようです。  
`self.メソッド名`の形式も一般的によく使われるので、両方覚えておくとよいでしょう。

## 3. ラムダについて

**lamda**と**Proc**について学習します。2つともほぼおなじ機能です。  
ラムダ式の定義は、関数を一級関数として扱う構文です。  
簡単に言うと、**関数をオブジェクトとして扱うことができるようになります**。

関数を変数に代入したり、メソッドの引数に渡したい時に、ラムダを利用します。

### 3-1. lambda

ラムダの定義は、以下のようになります。

```ruby
# {}ブロックを使った定義
変数 = lambda{|引数1, 引数2, ...|
  # 処理
}

# do~endブロックを使った定義
変数 = lambda do |引数1, 引数2, ...|
  # 処理
end
```

実際に例を見てみましょう。  
**ブロックをオブジェクトとして保存**し、呼び出す時に`オブジェクト名.call`で呼び出しているといった遅延評価にすぎないことがわかるでしょう。

**lambda.rb**

```ruby
# {}ブロックで定義したlambda
test_lambda = lambda { |name| puts "#{name}王子"}

# do~endブロックで定義したlambda
test_lambda2 = lambda do |name|
  puts "#{name}様"
end

actor = "ベジータ"
test_lambda.call(actor) # => ベジータ王子
test_lambda2.call(actor) # => ベジータ様
```

### 3-2. Proc

`Proc`について確認していきましょう。

`Proc`クラスの利用方法は、lambdaと似ています。`Proc`クラスをインスタンス化すると、Procオブジェクトが生成されます、

Procオブジェクトの定義は、以下のとおりです。

```ruby
# {}ブロックを使った定義
変数 = Proc.new {|引数1, 引数2, ...|
  # 処理
}

# do~endブロックを使った定義
変数 = Proc.new do |引数1, 引数2, ...|
  # 処理
end
```

例になります。  
`lambda`と同じです。**ブロックをオブジェクトとして保存**し、呼び出す時に`オブジェクト名.call`で呼び出しているといった遅延評価にすぎません。

**proc.rb**

```ruby
# {}ブロックで定義したProc
test_proc = Proc.new {|name| puts "#{name}王子"}

# do~endブロックで定義したProc
test_proc2 = Proc.new do |name|
  puts "#{name}様"
end

actor = "ベジータ"
test_proc.call(actor) # => ベジータ王子
test_proc2.call(actor) # => ベジータ様
````

`lambda`と`Proc`をここまで同じものだと説明しましたが、厳密には`return`の扱いや、引数の数などによって、挙動が異なります。  
本勉強会では、そこまで説明しません。興味があれば調べてみてください。

`lambda`と`Proc`のどちらを使えばいいか、となると思いますが、`lambda`を使うのがおすすめです。JavaやPythonでもlambdaが存在しますので、比較的馴染みやすいでしょう。  
Procを利用する場合は、lambdaとの違いを理解した上で使うようにしましょう。

## 4. ブロックの補足

ブロックは、これまで`each`メソッドであったり、`lambda`や`Proc`で見てきましたが、奥が深いので補足しておきます。

### 4-1. メソッドの引数にブロックを与える

メソッドの定義に引数パラメータとしてブロック与えることができます。  
`&引数名`がブロックを渡すという意味になります。
下記の例は、`&x`で引数を定義しています。

`&`の意味ですが、`&`を付けることで、実際に引数にブロックが渡された際に**Procオブジェクトに変換している**のです。

```ruby
# block_defineメソッドの定義
# ブロックを引数パラメータに指定
# &xはブロックが渡されると、Procオブジェクトに変換される
def block_define(&x)
  # Procオブジェクトのコールメソッドを呼び出す
  x.call("Donald John Trump")
end

# block_defineメソッドの呼び出し
# {}ブロックを引数として渡している
block_define {|name| p "#{name} 大統領"} # => "Donald John Trump 大統領"
block_define {|name| p "#{name} タワー"} # => "Donald John Trump タワー
```

もちろん、`{}`ブロックの形式だけでなく、`do`〜`end`の形式でも記述できます。

```ruby
# do~endブロックの形式でメソッドを実行
block_define do |name|
  p "#{name} 不動産王"} # => "Donald John Trump 不動産王"
end
```

ここで注意ですが、メソッドでブロックを引数として渡す場合は、引数を1つしか定義できません。以下の場合は、メソッドを定義できません。

```ruby
# これはエラーになる。
def block_define(&x, param)
end

# これもエラーになる。
def block_define(&x, &y)
end
```

つまるところ、<u>**引数として渡せるブロックは１つだけ**</u>ということです。

また、メソッド呼び出し時に`block_define {|name| p "#{name} 大統領"} `ではなく、`block_define({|name| p "#{name} 大統領"})`として呼び出すこともできないので注意してください。

### 4-2. yield

`yield`の説明に入りたいのですが、ここまでで以下のことがわかっています。

* ブロック引数は1つだけしか渡せない。
* メソッドの引数として定義する`&変数`はメソッド実行時にProcオブジェクトに変換される。
* `変数.call()`の形式でProcオブジェクトを呼び出すことができる。

前で説明したコードを再掲します。

```ruby
def block_define(&x)
  # Procオブジェクトのコールメソッドを呼び出す
  x.call("Donald John Trump")
end

block_define {|name| p "#{name} 大統領"} # => "Donald John Trump 大統領"
```

ここで以下の考え方を適用します。

* ブロック引数は1つだけしか渡せないので、`&変数`はなくてもよい。省略しよう。
* 呼び出し箇所を`変数.call()`と明示しなくてもよい。省略しよう。

これを反映したのが`yield`メソッドです。
上記のコードは、`yield`を利用すると、このようになります。

```ruby
def block_define
  # yieldメソッドでブロック内の処理を実行
  yield("Donald John Trump")
end

block_define {|name| p "#{name} 大統領"} # => "Donald John Trump 大統領"
```

色々省略されたのが`yield`の正体です。  
**`yield`はブロックを扱う上で、とてもよくでてくる**ので、ここまでの流れを反芻して理解を深めておくとよいでしょう。

### 4-3. ブロックを使った用途について

ここまでラムダにはじまるブロックの説明を延々としてきましたが、結局何が嬉しいのか、いまひとつイメージしづらかったと思いますので、少しだけ補足します。

たとえば、以下のようなメソッドがあるとします。
これは、10という数字を使って、利用者側が好きなことしてもらうメソッドです。

```ruby
def magic_10_number_black_box(proc_obj, input)
  proc_obj.call(10,input)
end
```

利用者Aは、「10を使って足し算をして標準出力する」として、`magic_10_number_black_box`メソッドを使います。

```ruby
proc = lambda {|x,y| puts x + y}

magic_10_number_black_box(proc,20) # => 30
magic_10_number_black_box(proc,30) # => 40
```

利用者Bは、「10回文字列を標準出力する」として、`magic_10_number_black_box`メソッドを使います。

```ruby
proc = lambda {|x,msg| puts msg * x}

magic_10_number_black_box(proc,"aaa ") # => aaa aaa aaa aaa aaa aaa aaa aaa aaa aaa
magic_10_number_black_box(proc,"bbb ") # => bbb bbb bbb bbb bbb bbb bbb bbb bbb bbb
```

簡単な例だったのですが、**メソッドを汎用化しておいて、メソッドの利用者に処理を委譲する**ことができていますね。

このように、使い方によっては、有効に活用できるはずです！  
ある意味、メソッドに対するメソッドのMix-inみたいなものですね。

`map`メソッドや`sort`メソッドもブロックの中に利用者の好きなメソッドを書いてるので、思い返してみるとよいです。

```ruby
# mapメソッド
["AAA","BBB","CCC"].map {|str| p str.downcase} # => ["aaa","bbb","ccc"]
["AAA","BBB","CCC"].map {|str| p str.capitalize} # => ["Aaa","Bbb","Ccc"]

# sortメソッド
 ["bb", "aaaaa", "ccc"].sort {|x,y| x.length <=> y.length} # => ["bb", "ccc", "aaaaa"]
 ["bb", "aaaaa", "ccc"].sort {|x,y| x <=> y} # => ["aaaaa", "bb", "ccc"]
```

### 4-4. ブロックの有無を判定するblock_given?

`block_given?`とは、引数としてブロックが与えられたかどうかを判定するためのメソッドです。

メソッド定義の中で`yield`が記述してあった場合に、ブロックがあるかどうかを判定し、あればブロックの中身を実行し、なければブロックを呼び出さないような処理を記述したいような場合に使います。

**block_non_exists.rb**

```ruby
def block_exists_box
  if block_given?
    (8..19).each do |num|
      puts "#{num}時は、#{yield(num)}"
    end
  else
    puts "ブロックは存在しなかったよ"
  end
end

puts "ブロックをつける--------"
block_exists_box do |num|
  case num
  when 9..18
    "会社にいる時間帯だよ"
  else
    "会社にいない時間帯だよ"
  end
end

puts "ブロックをつけない--------"
block_exists_box
```

実行すると、以下のようになります。  
ブロックの有無の判定ができていることがわかります。

```bash
$ ruby block_non_exists.rb
ブロックをつける--------
8時は、会社にいない時間帯だよ
9時は、会社にいる時間帯だよ
10時は、会社にいる時間帯だよ
11時は、会社にいる時間帯だよ
12時は、会社にいる時間帯だよ
13時は、会社にいる時間帯だよ
14時は、会社にいる時間帯だよ
15時は、会社にいる時間帯だよ
16時は、会社にいる時間帯だよ
17時は、会社にいる時間帯だよ
18時は、会社にいる時間帯だよ
19時は、会社にいない時間帯だよ
ブロックをつけない--------
ブロックは存在しなかったよ
```

## 5. おわり

ここまでのレッスンでRubyの全体像をなんとなく掴んでくれれば幸いです。  
総合演習問題にも取り組んでみましょう。  
難しく感じるかもしれませんが、こなすことでRailsの知識習熟に大変役立つはずです。
