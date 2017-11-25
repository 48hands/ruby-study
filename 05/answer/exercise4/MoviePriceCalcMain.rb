require './MovieUtil'

# メインメソッドの定義
def main
  movieCust = MovieUtil::MovieCustomer.new
  movieCust.info()
  MovieUtil::MoviePriceCalc.new(movieCust).calculate_price
end

# メインメソッドの実行
main