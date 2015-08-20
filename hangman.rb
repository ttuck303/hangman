def initialize_new_game

	dic = File.new("5desk.txt", 'r')
	@game_dictionary = dic.readlines
	@dict_entry_count = @game_dictionary.size
	@letters_guessed = []
	@body_parts_remaining = 6
	@secret_word = choose_random_word(@game_dictionary)
	@encoded_word = encode_word(@secret_word, @letters_guessed)
	@spaces_remaining = count_spaces_remaining(@encoded_word)

	puts "New game initialized!"
end

def word_length_ok?(sample_word, min_len = 5, max_len = 12)
	(min_len..max_len).include?(sample_word.strip.length)
end

def choose_random_word(game_dict_array)
	secret_word = game_dict_array[rand(game_dict_array.size-1)]
	word_length_ok?(secret_word) ? secret_word.downcase.strip : choose_random_word(game_dict_array)
end

def encode_word(secret_word, letters_guessed)
	output = ''
	secret_word.each_char do |character|
		if letters_guessed.include?(character)
			output << "#{character} "
		else
			output << '_ '
		end
	end
	output
end

def count_spaces_remaining(encoded_word)
	encoded_word.count("_")
end

def request_guess
	puts "Guess a letter!"
	guess = gets.chomp
end

def input_valid?(input, guessed_letters) #TO DO: make it check for numbers too!
	puts "You guessed '#{input}"
	if input.nil? || input.length == 0
		puts "Please enter something."
		false
	elsif input.length > 1
		puts "Please enter only 1 character."
		false
	elsif guessed_letters.include?(input.downcase)
		puts "You have already guessed #{input}, please guess a new character."
		false
	elsif input.match(/[[:alpha:]]{1}/)
		true
	end
end

def get_player_guess(guessed_letters)
	guess = request_guess
	if input_valid?(guess, guessed_letters)
		guess.downcase!
		guessed_letters << guess
		guess
	else
		get_player_guess(guessed_letters)
	end
end

def score_guess(guessed_letter)
	if @secret_word.include?(guessed_letter)
		puts "Yes, #{guessed_letter} is in the word!"
	else
		@body_parts_remaining -=1
		puts ":O #{guessed_letter} is not in the word!"
	end
end


def update_game_state
	@encoded_word = encode_word(@secret_word, @letters_guessed)
	@spaces_remaining = count_spaces_remaining(@encoded_word)
end

def display_game_state
	puts
	puts "---------------------------------------"
	puts 
	puts @encoded_word
	puts
	puts "Body parts left: #{@body_parts_remaining}"
	puts
	puts "Spaces remaining: #{@spaces_remaining}"
	puts
	puts "Letters guessed: #{@letters_guessed.join(', ')}"
	puts
	puts "---------------------------------------"
	puts
end


def did_player_win?
	@spaces_remaining <= 0
end

def did_player_lose?
	@body_parts_remaining <= 0
end

def is_game_over? #TO DO create a win and a loss message
	did_player_win? || did_player_lose?
end

def game_loop
	initialize_new_game
	#puts @secret_word
	update_game_state
	display_game_state
	until is_game_over?
		score_guess(get_player_guess(@letters_guessed))
		update_game_state
		display_game_state
	end
	puts "You WIN! :)" if did_player_win?
	puts "you LOSE =( The word was #{@secret_word}!" if did_player_lose?
end

game_loop



# now that there is a mostly-working hangman, next step is to create a saveable version
# first put a git version up there incase you need to go back

# then, divide game architecture into two parts:
	# game state variable (hash with everything in it)
	# architecture for running a game using a game state hash
	# add options to start a new game, load a game, or save a game

	# file type? Thinking YAML dump will be the best way to store

	# saving branch in git and jumping in


