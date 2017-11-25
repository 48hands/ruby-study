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

        # 誕生日が現在日よりも未来の場合、再帰処理
        if (age < 0)
          puts "未来日が入力されています。"
          get_customer_age
        else
          age
        end

      end

      # 顧客タイプを取得するメソッド
      def get_customer_type(age)
        begin
          print "* 一般の方は1,大学生は2,高校生は3,小中学生は4, 5歳以下は5を入力してください: "
          type = gets.chomp!.to_i
        rescue
          puts "入力が誤っています。"
          retry
        end

        if type < 1 || type > 5
          puts "入力が誤っています。"
          get_customer_type(age)
        elsif type == 5 && age > 5
          puts "年齢が不正です。"
          get_customer_type(age)
        else
          type
        end
        
      end

      # 映画の上映日時を取得するメソッド
      def get_movie_date
        begin
          print "* 映画の上映日時をyyyy-mm-dd hh:MMの形式で入力してください: "
          movie_datetime = Time.parse(gets.chomp!)
        rescue
          puts "入力形式が不正です。"
          retry
        end
        # 上映時刻が過去の場合、再帰処理
        if movie_datetime < Time.now
          puts "上映時刻に過去日時が入力されています。"
          get_movie_date
        else
          movie_datetime
        end
      end

      # 3Dかどうかを判定するメソッド
      def get_is_3D?
        print "* 3Dで観たい人はY,3Dで見たくない人はNを入力してください: "
        type = gets.chomp!.to_s
        case type
        when "Y"
          true
        when "N"
          false
        else
          puts "入力が誤っています。"
          get_is_3D?
        end
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
      price = set_basic_price
      if is_late_show?(@datetime) && price > LATE_SHOW_PRICE
        price = LATE_SHOW_PRICE
      elsif  is_ladies_day?(@datetime,@gender) && price > LADIES_DAY_PRICE
        price = LADIES_DAY_PRICE
      elsif is_movie_day?(@datetime) && price > MOVIE_DAY_PRICE
        price = MOVIE_DAY_PRICE
      end

      if @option_3D
        price += OPTION_3D_PRICE
      end
      
      puts "映画料金: #{price}円"

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
        datetime.hour >= 21
      end

      def is_ladies_day?(datetime,gender)
        datetime.wednesday? && gender == "F"
      end

      def is_movie_day?(datetime)
        datetime.day == 1
      end 

  end

end
