require "rainbow"
require "oj"

class Game 
  attr_reader :shown
  attr_reader :secret_word
  attr_reader :guesses_left
  attr_reader :letters_guessed

  def initialize
    @secret_word = pick_word.downcase.split("")
    @guesses_left = 9
    @shown = "_" * @secret_word.length
    @letters_guessed = []
    @saving = false
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
    while @guesses_left > 0 && !win_check? && !@saving do
      puts "You have " + Rainbow("#{@guesses_left}").orange + " turns left"
      puts "letters guessed: #{@letters_guessed}"
      puts "you have: #{@shown}"
      print "Your guess: "
      input = gets.downcase.chomp
      puts ""

      if (input == "save")
        @saving = true
        save
      elsif (@letters_guessed.include?(input))
        puts Rainbow("you already guess it").yellow
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

  def save 
    puts "Enter your save name: "
    file_name = gets.chomp
    file_path = "saved_games/#{file_name}"
    Dir.mkdir "saved_games" unless Dir.exists? "saved_games"

    File.open(file_path, 'w') do |file|
      file.puts Oj.dump self   
    end

    puts "Game saved"
  end

  def load 
    puts "Game saves:"
    saved_games = Dir.entries("saved_games").reject{|entry| entry == "." || entry == ".."}
    puts saved_games

    puts "Enter the save you wish to load"
    file_path = "saved_games/#{gets.chomp}"
    file = File.open(file_path, 'r')

    load = Oj.load(file)
    puts "Game loaded"

    @secret_word = load.secret_word
    @guesses_left = load.guesses_left
    @shown = load.shown
    @letters_guessed = load.letters_guessed
    @saving = false
  end


  def win_check? 
     @shown == @secret_word.join("")? true : false
  end

  def final_message
    if (@saving)
      puts Rainbow("Game saved succesfully").aqua
    elsif @guesses_left > 0 
      puts Rainbow("Congrats you won").green
      puts "You guessed " + Rainbow(@secret_word.join("")).cyan + " right"
    else
      puts "Aw better luck next time"
      puts "The correct word was " + Rainbow(@secret_word.join("")).cyan
    end
  end


  def game_loop 
    puts "Do you want a new game(1) or load game(2)"
    mode = gets.chomp
    if mode == "1"
      puts "enter " + Rainbow("save").orange + " anytime to save"
      guessing_loop
      final_message
    elsif mode == "2"
      load
      guessing_loop
      final_message
    end
  end
end

game = Game.new
game.game_loop