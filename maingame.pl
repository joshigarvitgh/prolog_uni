:- dynamic(knowledgeBase/1). %knowledgebase
:- dynamic(loadingstatus/1). %to check the status if the database is fully loaded
:- dynamic(databasefile/1). % what all are the files in the database
:- dynamic (loadedfiles/1). % same as databasefile, but it keeps on changing depending on if modification in some file done or not
:- dynamic selected_word/1. % this is the word for the gameplay
%Read the files and put the strings in the knowledge base
print_stars(0).
print_stars(N) :- N>0, write('*'),
           S is N-1, print_stars(S). 
%gameplay is the predicate for the guessword. the selected word and the print_stars is used to print stars
guessword:-
    bagof(X,knowledgeBase(X),W),
    random_member(M,W),
    atom_length(M,X),
    assert(selected_word(M)),         % TF: should be retracted at some point? maybe I've just overlooked that
    write('Please guess the word: '),
    print_stars(X),
    writeln(''),
    start_guessing.

readfacts(String0):-
    loadedfiles(String0),
      retract(loadedfiles(String0)),
    String0 \= end_of_file,
      open(String0,read,In),
    repeat,
    read_line_to_string(In,X),
    assert(knowledgeBase(X)),
    X=end_of_file,close(In).


readfacts(_):- knowledgeBase(end_of_file),retract(knowledgeBase(end_of_file)),!,readfacts(_).
readfacts(_):-!.

% starting point of the program where we maintain the status of loading
% , and the lsit of files for database
main_1:-
    assert(loadingstatus(0)),
open("db_file.txt",read,Lis),
    repeat,
    read_line_to_string(Lis,X),
    assert(databasefile(X)),
    assert(loadedfiles(X)),
    X=end_of_file,close(Lis),main_,!.

%menu of the program
main_:-
write("Please select from the below mentioned menu:"),nl,
write("r : To read the database file"),nl,
write("l : To list Knowledge Base"),nl,
write("a : To add new word"),nl,
write("d : To delete any word"),nl,
write("w : write database file"),nl,
write("g : Guess a word"),nl,
write("e : End the game"),nl,
    get_single_char(C),atom_codes(Y,[C]),check(Y).

check(r):-write("Please enter the file name"),read_string(user_input,"\n","\t",_,String0),checkfileindb(String0),!.
check(l):-listofKB,!.
check(a):-addword.
check(d):-deleteword,main_,!.
check(w):-writedb,main_,!.
check(g):-guessword(),main_,!.
check(e):-retractall(knowledgeBase/1),retractall(loadingstatus/1),retractall(databasefile/1),retractall(loadedfiles/1),halt.
check(_):-write("wrong choice"),nl,main_.

% Function for chacking the file, if its in database or not, if yes then
% it will also load the file
checkfileindb(String0):-databasefile(String0),readfacts(String0),main_,!.
checkfileindb(_):-write("File does not exist"),nl,main_,!.

% it will check if all the files are loaded in KB if not it will load
% them
listofKB:- loaddatabase,listing(knowledgeBase/1),main_,!.
listofKB:-write("Database is not loaded, please load Database"),nl,main_,!.

loaddatabase:- loadedfiles(X),readfacts(X),loaddatabase,!.
loaddatabase:- write("loading is completed"),assert(loadingstatus(1)),listing(knowledgeBase/1),main_,!.

% It will ask for word, will check first if KB is loaded, if yes and
% word doesnot exist in DB it will add the word else it will say word
% already exist, if KB is not loaded it will ask you to load the KB
addword:-write("Please write down the string:"), read_string(user_input,"\n","\t",_,String),write("Do you wanna save changes :"),write(String),nl, write("y or n"),nl,get_single_char(C),atom_codes(Y,[C]),checkAdd(Y,String) .
checkAdd(y,String):- checkKB(String).
checkAdd(n,_):-main_,!.
checkAdd(_,_):-write("wrong choice"),nl,main_,!.

checkKB(String):-loadingstatus(1), knowledgeBase(String),write("Word already exists"),nl,main_,!.
checkKB(String):-loadingstatus(1), assert(knowledgeBase(String)),write("Sucessfully Added!"),nl,main_,!.
checkKB(_):-loadingstatus(0), write("Database is not fully loaded yet, Please load the database first:)"),nl,main_,!.

% Function for deletion, will work same as adding
deleteword:-write("Please write down the string:"), read_string(user_input,"\n","\t",_,String1),write("Do you wanna save changes :"),write(String1),nl, write("y or n"),nl,get_single_char(C),atom_codes(Y,[C]),checkdlt(Y,String1) .
checkdlt(y,String1):- loadingstatus(1),knowledgeBase(String1),retract(knowledgeBase(String1)),write("Modification done"),nl,main_,!.
checkdlt(y,String1):- loadingstatus(0),knowledgeBase(String1),retract(knowledgeBase(String1)),write("Database is not fully loaded, please load the database first"),nl,main_,!.
checkdlt(y,_):-loadingstatus(1),write("String not availabele in KB"),nl,main_,!.
checkdlt(n,_):-main_,!.
checkdlt(_,_):-write("wrong choice"),nl,main_,!.

% writing a file in DB, if file already exists, it will ask if you wanna
% overwrite if yes it will over write, or if file does not exist it will
% create new one
writedb:-write("please enter the name of the file"),nl, read_string(user_input,"\n","\t",_,String2),checkfilename(String2),!.
checkfilename(String2):-databasefile(String2),write("File Already Exists, do you want to overwrite?"),nl,write("y or n"),nl,get_single_char(C),atom_codes(Y,[C]),checkoverwrite(Y,String2) .
checkfilename(String2):-open(String2,write,Out), read_string(user_input,"\n","\t",_,String3)
    ,write(Out,String3),close(Out),assert(loadedfiles(String2)),assert(databasefile(String2)),retractall(loadingstatus(_)),assert(loadingstatus(0)),main_,! .

checkoverwrite(y,String2):-open(String2,write,Out), read_string(user_input,"\n","\t",_,String3)
    ,write(Out,String3),close(Out),checkdbforfile(String2).
checkoverwrite(n,_):-write("Please Select Again"),nl,main_,!.
checkoverwrite(_,_):-write("Wrong Choice"),nl,main_,!.

checkdbforfile(String2):-loadedfiles(String2),write("Modification Done!"),nl,retractall(loadingstatus(_)),assert(loadingstatus(0)),main_,!.
checkdbforfile(String2):-assert(loadedfiles(String2)),reversereadfacts(String2),write("Modification Done!"),nl,retractall(loadingstatus(_)),assert(loadingstatus(0)),main_,!.
reversereadfacts(String2):-
    loadedfiles(String2),
    String2 \= end_of_file,
      open(String2,read,In),
    repeat,
    read_line_to_string(In,X),
    retract(knowledgeBase(X)),
    X=end_of_file,close(In).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TF: Word-Guessing part

% main function to be called for the guessing-part
start_guessing:-
    selected_word(Word),
    atom_chars(Word, LetterList),
    guess(LetterList, [], 0),
    retract(selected_word).

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


