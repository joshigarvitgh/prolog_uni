% create standalone executable file of prolog code:
% swipl -q -O -t main -o filename -c file.pl


% main function to be called for the guessing-part
start_guessing:-
    selected_word(Word),
    atom_chars(Word, LetterList),
    guess(LetterList, [], 0).

% called recursively in conjunction with end_game to keep the guessing game running
guess(LetterList, OldUserGuesses, CurrentGuessCount):-
    write('Please guess a letter: '),
    get_single_char(RawUserGuess),                                    % could add input checks? no numbers, only letters, only lower case??
    char_code(UserGuess, RawUserGuess),
    (member(UserGuess, OldUserGuesses) -> true ; append([UserGuess], OldUserGuesses, NewUserGuesses)),
    NewGuessCount is CurrentGuessCount + 1,
    write('Your solution:         '),
    printstatus(LetterList, NewUserGuesses, StarCount),
    end_game(LetterList, NewUserGuesses, NewGuessCount, StarCount).
    
% check if the game is finished, if so print the result, else continue with guess/3
end_game(_, _, GuessCount, 0):-
    !, writeln(''),
    write('Congratulations! It took you only '), write(GuessCount), writeln(' guesses.').
end_game(LetterList, UserGuesses, GuessCount, _):-
    guess(LetterList, UserGuesses, GuessCount).
    
% print combination of '*' and letters, depending on the guesses of the user
% as we have to traverse the whole LetterList once and for each of the letters in there
% check if the user has already guessed this letter, we double-use this function to
% track how many '*' are left
% TF: might change that in the future to separate the different functionalities
printstatus([], _, 0):-!, writeln('').
printstatus([LetterListHead | LetterListTail], UserGuesses, OldStarCount):-
    member(LetterListHead, UserGuesses), !,
    write(LetterListHead),
    printstatus(LetterListTail, UserGuesses, OldStarCount).
printstatus([_ | LetterListTail], UserGuesses, NewStarCount):-
    print_stars(1),
    printstatus(LetterListTail, UserGuesses, OldStarCount),
    NewStarCount is OldStarCount + 1.





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Database-stuff

% takes FileName as variable, asserts every word in this file to knowledgeBase, recursively calls main_
load_database(FileName):-
    open(FileName,read,InputList),
    repeat,
    read_line_to_string(InputList,Line),
    assert(knowledgeBase(Line)),
    Line=end_of_file, close(InputList),
    retract(knowledgeBase(end_of_file)).
    main_.
