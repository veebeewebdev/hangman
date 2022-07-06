class Hangman
  require 'csv'
  require 'yaml'

  attr_accessor :all_letters_found, :incorrect_choices, :display_gameboard_array, :array_of_match_indices,
                :chosen_word, :rounds

  def initialize(all_letters_found=[], incorrect_choices = [], display_gameboard_array = [], array_of_match_indices = [], chosen_word = '', rounds = 0)
    @all_letters_found = all_letters_found
    @incorrect_choices = incorrect_choices
    @display_gameboard_array = display_gameboard_array
    @array_of_match_indices = array_of_match_indices
    @chosen_word = chosen_word
    @rounds = rounds
  end

  def to_yaml

    @saved_game = {
                              "all_letters_found": @all_letters_found,
                              "incorrect_choices": @incorrect_choices,
                              "display_gameboard_array": @display_gameboard_array,
                              "array_of_match_indices": @array_of_match_indices,
                              "chosen_word": @chosen_word,
                              "rounds": @rounds
                            }
    File.open('saved_game.yml', 'w') { |file| file.write(@saved_game.to_yaml) }
  end

  def open_game
    data = YAML.load_file('saved_game.yml')

    @all_letters_found = data[:all_letters_found]
    @incorrect_choices = data[:incorrect_choices]
    @display_gameboard_array = data[:display_gameboard_array]
    @array_of_match_indices = data[:array_of_match_indices]
    @chosen_word = data[:chosen_word]
    @rounds = data[:rounds]
  end

  def choose_word
    @words = []
    @contents = CSV.open('google-10000-english-no-swears.txt', headers: false)
    @contents.each do |word|
      @words.push(word[0]) if 5 <= word[0].length && word[0].length <= 12
    end
    @chosen_word = @words.sample
  end

  def display_game_board(chosen_word, all_letters_found)
    if @display_gameboard_array.length == 0
      chosen_word.length.times do
        @display_gameboard_array.push(' _')
      end
    else

      all_letters_found.each do |letter_index_pair|
        @display_gameboard_array.delete_at(letter_index_pair[1])
        @display_gameboard_array.insert(letter_index_pair[1], letter_index_pair[0])
      end
    end
    @board_to_display = ''
    @display_gameboard_array.each { |space| @board_to_display = @board_to_display + ' ' + space.to_s }

    "\n#{@board_to_display}\n\n"
  end

  def player_letter_pick(chosen_word, letter = '')
    puts "Pick a letter\n"
    @letter = if letter == ''
                gets.chomp.downcase
              else
                letter
              end
    if chosen_word.include?(@letter)
      @array_of_match_indices = (0...chosen_word.length).find_all { |i| chosen_word[i, 1] == @letter }
      @array_of_match_indices.each do |i|
        @all_letters_found.push([@letter, i])
      end
    else
      @incorrect_choices.push(@letter)
    end
    "Incorrect choices: #{@incorrect_choices}\n"
  end

  def winner(chosen_word)
    true if @all_letters_found.length == chosen_word.length
  end

  def play
    puts 'Open saved game? y/n'
    @response = gets.chomp.downcase
    if @response == 'y'
open_game
    else
      @rounds = 0
      puts "Let's play!\n"
      @chosen_word = choose_word
    end
    until @rounds > 12

      puts display_game_board(@chosen_word, @all_letters_found)

      if winner(@chosen_word) == true

        puts "Winner! The word was #{@chosen_word}!\n"
        return
      elsif @rounds > 11
        puts "Out of guesses! The word was #{@chosen_word}.\n"
        return
      else
        puts "Enter 'yes' to save game, or pick a letter to play."
        @response = gets.chomp.downcase
        if @response == 'yes'
          to_yaml
          return
        else
          @rounds += 1
          puts player_letter_pick(@chosen_word, @response)
        end
      end
    end
  end
end

game = Hangman.new

game.play
