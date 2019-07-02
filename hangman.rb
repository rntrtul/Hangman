require "rainbow"

class Game 
  attr_reader :word_got
  attr_reader :secret_word

  def initialize
    @secret_word = pick_word.downcase.split("")
    @guesses_left = 9
    @shown = "_" * @secret_word.length
    @letters_guessed = []
  end

  def pick_word
    line = ""
    loop do
      line = File.readlines("5desk.txt").sample.chomp
      break if (line.length >= 5 && line.length <= 12)
    end
    line
  end
  
  def guess? letter
    @letters_guessed.push(letter)
    @secret_word.include?(letter)? true : false
  end

  def letter_pos letter
    positions = []
    @secret_word.each_with_index do |char, index|
       positions << index if(char == letter)
    end
    positions
  end

  def update_shown positions
    @secret_word.each_with_index do |letter, index|
      @shown [index] = letter if positions.include?(index)
    end
  end

  def guessing_loop
    while @guesses_left > 0 && !win_check? do
      puts "You have " + Rainbow("#{@guesses_left}").orange + " turns left"
      puts "letters guessed: #{@letters_guessed}"
      puts "you have: #{@shown}"
      puts "Your guess: "
      input = gets..downcase.chomp

      if (@letters_guessed.include?(input))
        puts Rainbow("you already guess it").red
        next
      else
        if(guess?(input))
          update_shown(letter_pos(input))
        else
          @guesses_left -=  1
          puts Rainbow("Wrong Guess").red
        end
      end
    end
  end

  def win_check? 
     @shown == @secret_word.join("")? true : false
  end

  def game_loop 
    puts "Do you want a new game(1) or load game(2)"
    if gets.chomp == "1"
      puts "enter " + Rainbow("save").orange + " anytime to save"
      guessing_loop
      if @guesses_left > 0 
        puts Rainbow("Congrats you won").green
        puts "You guessed " + Rainbow(@secret_word.join("")).cyan + " right"
      else
        puts "Aw better luck next time"
        puts "The correct word was " + Rainbow(@secret_word.join("")).cyan
      end
    end
  end
end

game = Game.new
game.game_loop