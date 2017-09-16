
## 総合演習

ここまでのレッスンまでで得た知識を総動員してチャレンジしてみましょう。

<u>**演習問題1(難易度:低)**</u>

ダックタイピングを利用しない実装`CaseSample.rb`とダックタイピングを利用した`DuckSample.rb`を写経してみましょう。

さらに、お肉、スナックをどちらのコードに対しても追加してみましょう。  
ビジネスロジックに改修が発生するのはどちらでしょう？

**CaseSample.rb**

```ruby
class Food
  # 料理する(ビジネスロジック)
  def self.cook(foods)
    foods.each do |food|
      case food[:type]
      when "Fruit"
        puts "フルーツ(#{food[:name]})の皮を剥くよ"
      when "Vegetable"
        puts "野菜(#{food[:name]})を切るよ"
        puts "野菜 #{food[:name]})を焼くよ"
      end
    end
  end
end

foods = [
  { type: "Fruit", name: "みかん" },
  { type: "Vegetable", name: "キャベツ" },
]

Food.cook(foods)
```

**DuckSample.rb**

```ruby
class Food
  def initialize(name)
    @name = name
  end

  # 料理する(ビジネスロジック)
  def self.cook(foods)
    foods.each do |food|
      food.cuisine
    end
  end

end

class Vegetable < Food
  def cuisine
    puts "野菜(#{@name})を切るよ"
    puts "野菜(#{@name})を焼くよ"
  end

end

class Fruit < Food
  def cuisine
    puts "フルーツ(#{@name})の皮を剥くよ"
  end

end

foods = [Vegetable.new("しいたけ"),Fruit.new("ピンクグレープフルーツ")]
Food.cook(foods)
```

<u>**演習問題2(難易度:中)**</u>

円の面積を求めるブロックと正方形の円を求めるブロックを定義して、半径と辺の長さがそれぞれ5~10の場合の面積を求めてみましょう。  
`# FIXME`の部分を実装してください。

**calArea.rb**

```ruby
def get_area_size(proc,x)
  proc.call(x)
end

# 円の面積を求めるブロックを定義する
circle_cal_block = # FIXME
# 正三角形の面積を求めるブロックを定義する
triangle_cal_block = # FIXME

# FIXME
```

**実行結果**

```bash
$ ruby calArea.rb
--------
半径5の円の面積: 78.5
一辺5の正方形の面積: 25
--------
半径6の円の面積: 113.04
一辺6の正方形の面積: 36
--------
半径7の円の面積: 153.86
一辺7の正方形の面積: 49
--------
半径8の円の面積: 200.96
一辺8の正方形の面積: 64
--------
半径9の円の面積: 254.34
一辺9の正方形の面積: 81
--------
半径10の円の面積: 314.0
一辺10の正方形の面積: 100
```

<u>**演習問題3(難易度:中)**</u>

自然言語処理にチャレンジしてみましょう。太宰治の書籍「人間失格」の中ででてくる名詞top50を出力し、最頻出の名詞を当ててみましょう。  
骨格となるプログラムは以下を利用してください。  
`# FIXME`の部分を実装してください。

**countNoun.rb**

```ruby
require 'natto'

noun_count = Hash.new(0)
natto = Natto::MeCab.new

File.open(ARGV[0]) do |f|
  f.each_line do |line|
    line.chomp!
    natto.parse(line) do |n|
      # FIXME ヒントを参照してください。
    end
  end
end

sorted_hash = noun_count.sort{
  # FIXME
}

# FIXME トップ50を出力してください。
```

**実行結果**

```
$ ruby countNoun.rb /tmp/ningen_shikkaku_utf8.txt
...
学校: 35
ため: 35
いま: 35
頃: 34
部屋: 33
恐怖: 32
れい: 3
```

**この問題を解くには、事前準備が必要になります。**
事前準備は、以下を参考にしてください。

<u>事前準備</u>

```bash
# 形態素解析ライブラリMecabのインストール
$ sudo apt-get update
$ sudo apt-get install mecab libmecab-dev mecab-ipadic-utf8 nkf

# Mecabがインストールできたか確認
$ echo "きっとインストールできているはずです" | mecab
きっと  副詞,一般,*,*,*,*,きっと,キット,キット
インストール    名詞,一般,*,*,*,*,インストール,インストール,インストール
でき    動詞,自立,*,*,一段,連用形,できる,デキ,デキ
て      助詞,接続助詞,*,*,*,*,て,テ,テ
いる    動詞,非自立,*,*,一段,基本形,いる,イル,イル
はず    名詞,非自立,一般,*,*,*,はず,ハズ,ハズ
です    助動詞,*,*,*,特殊・デス,基本形,です,デス,デス
EOS

# RubyでMecabを使うために、nattoをインストールする
$ gem install natto
Successfully installed natto-1.1.1

# 青空文庫から書籍をダウンロード,解答
$ wget http://www.aozora.gr.jp/cards/000035/files/301_ruby_5915.zip
$ unzip 301_ruby_5915.zip
# sjisなのでutf8に変換
$ nkf -u ningen_shikkaku.txt  > /tmp/ningen_shikkaku_utf8.txt
```

<u>(ヒント)</u>  
以下のプログラムがヒントになります。  
実行してみると..

**sample_mecab.rb**

```ruby
require 'natto'
 
text = "おなかが減ってぺこぺこです。"
 
natto = Natto::MeCab.new
natto.parse(text) do |n|
  puts "#{n.surface}: #{n.feature}"
end
```


<u>**演習問題4(難易度:高)**</u>

ユーザと対話式で映画の料金を算出するプログラムを作成してください。  
料金体系は以下の通りです。

* 基本料金
  * 一般: 1,800円
  * 大学生: 1,500円
  * 高校生: 1,200円
  * 小中学生: 1,000円
  * 5歳以下:無料

* 特別割り引き
  * 映画の日: 1,000円(毎月1日)
  * レディースデイ: 1,200円(毎週水曜日)
  * レイトショー: 1,500円(21時以降)
  * 複数の割り引き条件が重なる場合は、最大の割り引きとなる条件を一つ選ぶ。
* 追加オプション
    * 3Dの場合はプラス400円(2Dは追加料金なし)

骨格となるプログラムは以下を利用してください。  
`# FIXME`の部分を実装してください。

**MoviePriceCalcMain.rb**

```ruby
require './MovieUtil'

# メインメソッドの定義
def main
  movieCust = MovieUtil::MovieCustomer.new
  movieCust.info()
  MovieUtil::MoviePriceCalc.new(movieCust).calculate_price
end

# メインメソッドの実行
main
```

**MovieUtil.rb**

```ruby
require 'time'
require 'date'

module MovieUtil

  class MovieCustomer
    attr_reader :gender, :age, :type, :movie_date, :option_3D

    def initialize
      @gender = get_gender
      @age = get_customer_age
      @type = get_customer_type(@age)
      @movie_date = get_movie_date
      @option_3D = get_is_3D?
    end

    def info
      puts "------------------"
      puts "顧客情報"
      puts " 性別: #{@gender}"
      puts " 年齢: #{@age}"
      puts " 顧客タイプ: #{@type}"
      puts " 映画上映時間: #{@movie_date}"
      puts " 3D希望: #{@option_3D}"
      puts "------------------"
    end

    private
      # 性別を取得するメソッド
      def get_gender
        print "* 男性はM,女性はFで性別を入力してください: "
        gender = gets.chomp!

        if gender != "M" && gender != "F"
          puts "入力が間違っています。正しい値を入力してください。"
          get_gender()
        else
          gender
        end

      end

      # 顧客の年齢を取得するメソッド
      def get_customer_age
        begin
          print "* 誕生日をyyyy-mm-ddの形式で入力してください: "
          birthday = Date.parse(gets.chomp!)
        rescue
          puts "入力形式が不正です。"
          retry
        end

        age = (Date.today.strftime('%Y%m%d').to_i - birthday.strftime('%Y%m%d').to_i) / 10000

        # 誕生日が現在日よりも未来の場合、再帰処理
        if (age < 0)
          puts "未来日が入力されています。"
          get_customer_age
        else
          age
        end

      end

      # 顧客タイプを取得するメソッド
      def get_customer_type(age)
        # FIXME
      end

      # 映画の上映日時を取得するメソッド
      def get_movie_date
        # FIXME
      end

      # 3Dかどうかを判定するメソッド
      def get_is_3D?
        # FIXME
      end

  end

  class MoviePriceCalc
    GENERAL_PRICE = 1800
    UNIVERSITY_STUDENT_PRICE = 1500
    HIGH_SCHOOL_STUDENT_PRICE = 1200
    ELEMENTARY_SHOOL_STUDENT_PRICE = 1000
    UNDER_5YEARS_OLD_PRICE = 0

    MOVIE_DAY_PRICE = 1000
    LADIES_DAY_PRICE = 1200
    LATE_SHOW_PRICE = 1500

    OPTION_3D_PRICE = 400

    def initialize(customer)
      @datetime = customer.movie_date
      @type = customer.type
      @gender = customer.gender
      @age = customer.age
      @option_3D = customer.option_3D
    end

    def calculate_price
      # FIXME
    end

    private
      def set_basic_price
        price = case @type
          when 1 then GENERAL_PRICE
          when 2 then UNIVERSITY_STUDENT_PRICE
          when 3 then HIGH_SCHOOL_STUDENT_PRICE
          when 4 then ELEMENTARY_SHOOL_STUDENT_PRICE
          else
            UNDER_5YEARS_OLD_PRICE
          end
      end

      def is_late_show?(datetime)
        # FIXME
      end

      def is_ladies_day?(datetime,gender)
        # FIXME
      end

      def is_movie_day?(datetime)
        # FIXME
      end

  end

end

```

**実行イメージ**

```bash
$ ruby MoviePriceCalcMain.rb
* 男性はM,女性はFで性別を入力してください: M
* 誕生日をyyyy-mm-ddの形式で入力してください: 1990-01-01
* 一般の方は1,大学生は2,高校生は3,小中学生は4, 5歳以下は5を入力してください: 5
年齢が不正です。
* 一般の方は1,大学生は2,高校生は3,小中学生は4, 5歳以下は5を入力してください: 1
* 映画の上映日時をyyyy-mm-dd hh:MMの形式で入力してください: 1988-11-01 14:00
上映時刻に過去日時が入力されています。
* 映画の上映日時をyyyy-mm-dd hh:MMの形式で入力してください: 2018-01-01 22:00
* 3Dで観たい人はY,3Dで見たくない人はNを入力してください: Y
------------------
顧客情報
 性別: M
 年齢: 27
 顧客タイプ: 1
 映画上映時間: 2018-01-01 22:00:00 +0900
 3D希望: true
------------------
映画料金: 1900円
```
