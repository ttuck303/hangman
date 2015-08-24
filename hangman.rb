require 'yaml'

def initialize_new_game
	puts Dir.pwd
	@state_var = {}
	dic = File.new("5desk.txt", 'r')
	game_dictionary = dic.readlines
	dict_entry_count = game_dictionary.size
	letters_guessed = []
	body_parts_remaining = 6
	secret_word = choose_random_word(game_dictionary)
	encoded_word = encode_word(secret_word, letters_guessed)
	spaces_remaining = count_spaces_remaining(encoded_word)
	# check if a saved_game folder exists, and if it doesn't, create one
	Dir.mkdir("saved_games") if !Dir.exists?("saved_games")
	@state_var = {:letters_guessed => letters_guessed, :body_parts_remaining => body_parts_remaining, :secret_word => secret_word, :encoded_word => encoded_word, :spaces_remaining => spaces_remaining}
	puts @state_var
	puts @state_var.inspect

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
	if @state_var[:secret_word].include?(guessed_letter)
		puts "Yes, #{guessed_letter} is in the word!"
	else
		@state_var[:body_parts_remaining] -=1
		puts ":O #{guessed_letter} is not in the word!"
	end
end


def update_game_state
	@state_var[:encoded_word] = encode_word(@state_var[:secret_word], @state_var[:letters_guessed])
	@state_var[:spaces_remaining] = count_spaces_remaining(@state_var[:encoded_word])
end

def display_game_state
	puts
	puts "---------------------------------------"
	puts 
	puts @state_var[:encoded_word]
	puts
	puts "Body parts left: #{@state_var[:body_parts_remaining]}"
	puts
	puts "Spaces remaining: #{@state_var[:spaces_remaining]}"
	puts
	puts "Letters guessed: #{@state_var[:letters_guessed].join(', ')}"
	puts
	puts "---------------------------------------"
	puts
end


def did_player_win?
	@state_var[:spaces_remaining] <= 0
end

def did_player_lose?
	@state_var[:body_parts_remaining] <= 0
end

def is_game_over? #TO DO create a win and a loss message
	did_player_win? || did_player_lose?
end

def save_game
	# convert state variable to yaml compressed file
	docked_game_state = YAML.dump(@state_var)
	# create a new file in the saved folder file path with an interative file name

	time_stamp = Time.now.to_s
	file_path = "saved_games"
	existing_game_count = Dir.entries("#{Dir.pwd}/#{file_path}").size
	file_name = "Hangman - #{existing_game_count} - #{time_stamp}"
	save_file = File.new("#{file_path}/#{file_name}", 'w')

	# write the yaml contents to the file
	save_file.write(docked_game_state)
		# close the file so that it saves
	save_file.close
end

def load_game
	# load the text file, then unwrap the YAML
	# how do you specify which file to load? Is there a better way than typing out the file path?
end

def select_game
	# load the file names from a saved folder 
	# display as a numbered menu
	# get user input by reading in text
end




def game_loop
	initialize_new_game
	save_game
	#puts @secret_word
	update_game_state
	display_game_state
	until is_game_over?
		score_guess(get_player_guess(@state_var[:letters_guessed]))
		update_game_state
		display_game_state
	end
	puts "You WIN! :)" if did_player_win?
	puts "you LOSE =( The word was #{@state_var[:secret_word]}!" if did_player_lose?
	save_game
end

#game_loop






