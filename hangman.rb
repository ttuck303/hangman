require 'yaml'

def initialize_new_game_vars
	dic = File.new("5desk.txt", 'r')
	game_dictionary = dic.readlines
	dict_entry_count = game_dictionary.size
	letters_guessed = []
	body_parts_remaining = 6
	secret_word = choose_random_word(game_dictionary)
	encoded_word = encode_word(secret_word, letters_guessed)
	spaces_remaining = count_spaces_remaining(encoded_word)
	@state_var = {:letters_guessed => letters_guessed, :body_parts_remaining => body_parts_remaining, :secret_word => secret_word, :encoded_word => encoded_word, :spaces_remaining => spaces_remaining}
end

def initialize_game(state_var)
	@state_var = state_var
	puts "State var set to #{state_var}"
end

def display_debug_info
	puts @state_var
	puts Dir.pwd
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
	Dir.mkdir("saved_games") if !Dir.exists?("saved_games") # this should be in the save game sequece
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
	puts "Game saved!"
end

#refactor the loading game process
#each individual operation should have its own method




# (maybe go one level of abstraction higher on this)


# overall structure should be
# method for loading a game from a game state
# method for creating a brand new game state
# initialization routine should ask if you would like to start a new game or load one


def get_saved_games(game_path = "saved_games", regex_criteria = "Hangman - ")
	output = []
	existing_games = Dir.entries("#{Dir.pwd}/#{game_path}")
	existing_games.each { |fname| output << fname if fname.match(regex_criteria)}
	output.sort
end

def prompt_with_game_list(games)
	puts "Enter the number of the game file you would like to load: "
	games.each_with_index {|game, idx| puts "#{idx} : #{game}"}
	puts
end

def get_and_check_user_input_loading(list_length)
	user_input = gets.strip.to_i
	puts "You selected #{user_input}"
	display_debug_info
	return user_input if (0..list_length-1).include?(user_input)
	puts "Illegal entry, please try another number..."
	get_and_check_user_input_loading(list_length)
end

def select_game

	choice = gets.strip.to_i
	# TO-DO! clean and check the user input (for now just assume its good)
	puts "You chose number #{choice}, #{saved_games[choice]}"
	#return the choice as a File
	saved_game_file = File.open("#{Dir.pwd}/saved_games/#{saved_games[choice]}", "r")
	#load the yaml of the file
	saved_yaml_file = YAML.load(saved_game_file)
	puts saved_yaml_file

end

def load_game_sequence(game_path="saved_games")
	# retrieve the list of saved games from a given folder and return it as an array
	# take a game array and ask the user to select a game from a numbered list 
	# get the user input, and checks that its a number and that its in range, and returns that number
	# take and returns an UnYaml-ed game state object
	#load the yaml of the file

	saved_games = get_saved_games(game_path)
	prompt_with_game_list(saved_games)
	user_selection = get_and_check_user_input_loading(saved_games.size)
	saved_game_file = File.open("#{Dir.pwd}/#{game_path}/#{saved_games[user_selection]}", "r")
	puts "saved_game_file #{saved_game_file}"
	unwrapped_game_state = YAML.load(saved_game_file)
	puts "unwrapped_game_state #{unwrapped_game_state}"
	unwrapped_game_state
	#To-DO! Once this has been tested, collapse it down into a single line or two

	# start a game from the game state variable
end

def new_or_load
	puts "To start a new game, enter 1"
	puts "To load an existing game, enter 2"
	user_input = gets.strip.to_i
	if user_input == 1
		initialize_game(initialize_new_game_vars)
	elsif user_input == 2
		initialize_game(load_game_sequence)
	else
		puts "Invalid entry"
		new_or_load
	end
end

def ask_to_save_game
	puts "Would you like to save the game? [y/n]"
	user_input = gets.strip
	save_game if user_input == 'y'
end


def game_loop
	new_or_load
	update_game_state
	display_game_state
	until is_game_over?
		#display_debug_info
		score_guess(get_player_guess(@state_var[:letters_guessed]))
		update_game_state
		display_game_state
		#ask_to_save_game
	end
	puts "You WIN! :)" if did_player_win?
	puts "you LOSE =( The word was #{@state_var[:secret_word]}!" if did_player_lose?
	5.times {puts}
	game_loop
end

game_loop





