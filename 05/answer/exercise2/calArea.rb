def get_area_size(proc,x)
  proc.call(x)
end
# 円の面積を求めるブロックを定義する
circle_cal_proc = lambda {|r| r * r * 3.14}
# 正方形の面積を求めるブロックを定義する
square_cal_proc = lambda {|x| x * x}

(5..10).each do |x|
  puts "--------"
  puts "半径#{x}の円の面積: #{get_area_size(circle_cal_proc,x)}"
  puts "一辺#{x}の正方形の面積: #{get_area_size(square_cal_proc,x)}"
end