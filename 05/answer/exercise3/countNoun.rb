require 'natto'

noun_count = Hash.new(0)
natto = Natto::MeCab.new

File.open(ARGV[0]) do |f|
  f.each_line do |line|
    line.chomp!
    natto.parse(line) do |n|
      noun_count[n.surface] += 1 if n.feature.split(",")[0] == "名詞"
      # puts "#{n.surface}: #{n.feature}"
    end
  end
end

sorted_hash = noun_count.sort{
  |a,b| b[1] <=> a[1]
}

sorted_hash.first(50).each do |key,value|
  puts "#{key}: #{value}"
end
