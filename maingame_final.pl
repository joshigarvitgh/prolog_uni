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
    assert(selected_word(M)),
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
    X=end_of_file,close(In),
    retract(knowledgeBase(end_of_file)).                    % TF: added so we don't have multiple end_of_file-atoms in knowledgeBase


readfacts(_):- knowledgeBase(end_of_file),retract(knowledgeBase(end_of_file)),!,readfacts(_).
readfacts(_):-!.

%looping on entris
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
    
    check(r):-writeln("Please enter the file name"),read_string(user_input,"\n","\t",_,String0),checkfileindb(String0),main_,!.
    check(l):-listingSubroutine, main_, !.
    check(a):-addword,main_,!.               % requires loadinig of all files from the database to memory in order to avoid duplicate entries, use "l" from menu for this
    check(d):-deleteword,main_,!.      % requires loadinig of all files from the database to memory in order to avoid duplicate entries, use "l" from menu for this
    check(w):-writedb,main_,main_,!.
    check(g):-guessword(),main_,!.
    check(e):-retractall(knowledgeBase(_)),retractall(loadingstatus(_)),retractall(databasefile(_)),retractall(loadedfiles(_)),!.
    check(_):-write("wrong choice"),nl,main_.



listingSubroutine:-
    writeln("Load all files before listing KB?"), writeln("y or n"),
    get_single_char(Input),atom_codes(Letter, [Input]), listingCheckInput(Letter).
listingCheckInput('y'):-!, listofKB.
listingCheckInput('n'):-!, listing(knowledgeBase/1).
listingCheckInput(_):-writeln("wrong choice").

% Function for chacking the file, if its in database or not, if yes then
% it will also load the file
checkfileindb(String0):-
    exists_file(String0),
    retractall(knowledgeBase(_)),
    readfacts(String0), !.
checkfileindb(_):-write("File does not exist"),nl,!.
% it will check if all the files are loaded in KB if not it will load
% them
listofKB:- loaddatabase,listing(knowledgeBase/1),!.
listofKB:-write("Database is not loaded, please load Database"),nl,!.

loaddatabase:- loadedfiles(X),readfacts(X),loaddatabase,!.
loaddatabase:- write("loading is completed"),assert(loadingstatus(1)),listing(knowledgeBase/1),!.

% It will ask for word, will check first if KB is loaded, if yes and
% word doesnot exist in DB it will add the word else it will say word
% already exist, if KB is not loaded it will ask you to load the KB
addword:-write("Please write down the string:"), read_string(user_input,"\n","\t",_,String),write("Do you wanna save changes :"),write(String),nl, write("y or n"),nl,get_single_char(C),atom_codes(Y,[C]),checkAdd(Y,String) .
checkAdd(y,String):- checkKB(String).
checkAdd(n,_):-!.
checkAdd(_,_):-write("wrong choice"),nl,!.

checkKB(String):-loadingstatus(1), knowledgeBase(String),write("Word already exists"),nl,!.
checkKB(String):-loadingstatus(1), assert(knowledgeBase(String)),write("Sucessfully Added!"),nl,!.
checkKB(_):-loadingstatus(0), write("Database is not fully loaded yet, Please load the database first:)"),nl,!.

% Function for deletion, will work same as adding
deleteword:-write("Please write down the string:"), read_string(user_input,"\n","\t",_,String1),write("Do you wanna save changes :"),write(String1),nl, write("y or n"),nl,get_single_char(C),atom_codes(Y,[C]),checkdlt(Y,String1) .
checkdlt(y,String1):- loadingstatus(1),knowledgeBase(String1),retract(knowledgeBase(String1)),write("Modification done"),nl,!.
checkdlt(y,String1):- loadingstatus(0),knowledgeBase(String1),retract(knowledgeBase(String1)),write("Database is not fully loaded, please load the database first"),nl,!.
checkdlt(y,_):-loadingstatus(1),write("String not availabele in KB"),nl,!.
checkdlt(n,_):-!.
checkdlt(_,_):-write("wrong choice"),nl,!.

% writing a file in DB, if file already exists, it will ask if you wanna
% overwrite if yes it will over write, or if file does not exist it will
% create new one
writedb:-write("please enter the name of the file"),nl, read_string(user_input,"\n","\t",_,String2),checkfilename(String2),!.
checkfilename(String2):-exists_file(String2),write("File Already Exists, do you want to overwrite?"),nl,write("y or n"),nl,get_single_char(C),atom_codes(Y,[C]),checkoverwrite(Y,String2) .
checkfilename(String2):-open(String2,write,Out), read_string(user_input,"\n","\t",_,String3)
    ,write(Out,String3),close(Out),assert(loadedfiles(String2)),assert(databasefile(String2)),retractall(loadingstatus(_)),assert(loadingstatus(0)),! .

checkoverwrite(y,String2):-open(String2,write,Out), read_string(user_input,"\n","\t",_,String3)
    ,write(Out,String3),close(Out),checkdbforfile(String2).
checkoverwrite(n,_):-write("Please Select Again"),nl,!.
checkoverwrite(_,_):-write("Wrong Choice"),nl,!.

checkdbforfile(String2):-loadedfiles(String2),write("Modification Done!"),nl,retractall(loadingstatus(_)),assert(loadingstatus(0)),!.
checkdbforfile(String2):-assert(loadedfiles(String2)),reversereadfacts(String2),write("Modification Done!"),nl,retractall(loadingstatus(_)),assert(loadingstatus(0)),!.
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
    retract(selected_word(Word)).

% called recursively in conjunction with end_game to keep the guessing game running
guess(LetterList, OldUserGuesses, CurrentGuessCount):-
    write('Please guess a letter: '),
    get_single_char(RawUserGuess),
    char_code(UserGuess, RawUserGuess),
    (member(UserGuess, OldUserGuesses) -> append([], OldUserGuesses, NewUserGuesses) ; append([UserGuess], OldUserGuesses, NewUserGuesses)),
    NewGuessCount is CurrentGuessCount + 1,
    write('Your solution:         '),
    printstatus(LetterList, NewUserGuesses),
    end_game(LetterList, NewUserGuesses, NewGuessCount).

% check if the game is finished, if so print the result, else continue with guess/3
end_game(LetterList, UserGuesses, GuessCount):-
    word_complete(LetterList, UserGuesses), !,
    writeln(''),
    write('Congratulations! It took you only '), write(GuessCount), writeln(' guesses.').
end_game(LetterList, UserGuesses, GuessCount):-
    guess(LetterList, UserGuesses, GuessCount).

% we check if every letter in the word (Letterlist) was guessed by the user, only
% then will we evaluate to true
word_complete([], _):-!.
word_complete([LetterListHead | LetterListTail], UserGuesses):-
    member(LetterListHead, UserGuesses),
    word_complete(LetterListTail, UserGuesses).

% print combination of '*' and letters, depending on the guesses of the user
printstatus([], _):-!, writeln('').
printstatus([LetterListHead | LetterListTail], UserGuesses):-
    member(LetterListHead, UserGuesses), !,
    write(LetterListHead),
    printstatus(LetterListTail, UserGuesses).
printstatus([_ | LetterListTail], UserGuesses):-
    print_stars(1),
    printstatus(LetterListTail, UserGuesses).

