class Dictionary
  def pick_word
    line = ""

    loop do
      line = File.readlines("5desk.txt").sample
      break if (line.length >= 5 && line.length <= 12 )
    end
    line
  end
end

dic = Dictionary.new
puts  dic.pick_word