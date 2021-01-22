:- dynamic knowledgeBase/1.
:- dynamic selected_word/1.
members(W) :- bagof(X,knowledgeBase(X),W).
loop(0).  
loop(N) :- N>0, write('*'),
           S is N-1, loop(S).  

main:-
    assert(knowledgeBase("cat")),
    assert(knowledgeBase("human")),
    assert(knowledgeBase("dog")),
    bagof(X,knowledgeBase(X),W),
    random_member(M,W),
    write(M),
    atom_length(M,X),
    assert(selected_word(M)),
    loop(X),
    listing(selected_word).
    
    
    
    