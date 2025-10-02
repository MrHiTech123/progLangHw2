equals(A, A).


matchKeyToValue([KeysHead | KeysTail], [ValuesHead | ValuesTail], Key, Value) :-
	equals(KeysHead, Key), equals(ValuesHead, Value);
	matchKeyToValue(KeysTail, ValuesTail, Key, Value).


matchGamePluralityToPlurality(GamePlurality, Plurality) :- 
	matchKeyToValue([game, games], [singular, plural], GamePlurality, Plurality).

matchPluralityToAllowPlurality(Plurality, AllowPlurality) :-
	matchKeyToValue([singular, plural], [allows, allow], Plurality, AllowPlurality).

matchPluralityToTakePlurality(Plurality, TakePlurality) :-
	matchKeyToValue([singular, plural], [takes, take], Plurality, TakePlurality).



word(WordBeingTested, [WordBeingTested | S], S).


nounPhrase(Plurality, [HaystackHead | HaystackTail], [Needle | RestOfEnteredList], RestOfEnteredList) :- 
	(
		equals(HaystackHead, Needle);
		nounPhrase(Plurality, HaystackTail, [Needle | RestOfEnteredList], RestOfEnteredList)
	),
	matchGamePluralityToPlurality(Needle, Plurality).

number(Num, [Num | S], S) :- integer(Num).

verbPhraseAllowsForPlayers(Query, Plurality, [AllowVerbThatGameDoes | S0], S) :-
	matchPluralityToAllowPlurality(Plurality, AllowVerbThatGameDoes),
	word(for, S0, S1),
	number(NumberOfPlayers, S1, S2),
	word(players, S2, S),
	equals(Query, [allow_players, NumberOfPlayers]).
	
	
verbPhraseTakesMinutes(Query, Plurality, [TakeVerbThatGameDoes | S0], S) :-
	matchPluralityToTakePlurality(Plurality, TakeVerbThatGameDoes),
	word(less, S0, S1),
	word(than, S1, S2),
	number(NumberOfMinutes, S2, S3),
	word(minutes, S3, S),
	equals(Query, [time_check, NumberOfMinutes]).

verbPhrase(Query, Plurality, [VerbThatGameDoes | VerbPhraseTail], S) :-
	verbPhraseAllowsForPlayers(Query, Plurality, [VerbThatGameDoes | VerbPhraseTail], S);
	verbPhraseTakesMinutes(Query, Plurality, [VerbThatGameDoes | VerbPhraseTail], S).



question(Query, Plurality, S0, S) :- 
	word(which, S0, S1),
	nounPhrase(Plurality, [game, games], S1, S2),
	verbPhrase(Query, Plurality, S2, S).
	
answerQuery([QueryType, Argument], Answer) :-
	equals(QueryType, time_check), game(Answer), playing_time(Answer, PlayingTime), PlayingTime < Argument;
	equals(QueryType, allow_players), game(Answer), min_players(Answer, MinPlayers), max_players(Answer, MaxPlayers), (MinPlayers =< Argument), (MaxPlayers >= Argument).

answerQuestionList(QuestionList, Answer) :-
	question(Query, Plurality, QuestionList, []),
	(equals(Plurality, singular); equals(Plurality, plural)),
	answerQuery(Query, Answer).

listPop([Head | Tail], Index, ResultElement, [ResultListHead | ResultListTail]) :-
	equals(Index, 0), equals(Tail, [ResultListHead | ResultListTail]), equals(ResultElement, Head);
	not(equals(Index, 0)), MinusOne is Index - 1, equals(ResultListHead, Head), listPop(Tail, MinusOne, ResultElement, ResultListTail).

listInsert([Head | Tail], Index, InsertedElement, [ResultListHead | ResultListTail]) :-
	equals(Index, 0), equals([Head | Tail], ResultListTail), equals(ResultListHead, InsertedElement);
	not(equals(Index, 0)), MinusOne is Index - 1, equals(ResultListHead, Head), listInsert(Tail, MinusOne, InsertedElement, ResultListTail).





preProcessQuestionTimeCheck(Question, QuestionList) :-
	atomic_list_concat(RawQuestionList, " ", Question),
	write(RawQuestionList),
	listPop(RawQuestionList, 5, AtomNumberOfMinutes, NumberPoppedList),
	atom_number(AtomNumberOfMinutes, NumberOfMinutes),
	listInsert(NumberPoppedList, 5, NumberOfMinutes, QuestionList).
	
preProcessQuestion(Question, QuestionList) :- 
	preProcessQuestionTimeCheck(Question, QuestionList).

answerQuestionString(Question, Answer) :- 
	preProcessQuestion(Question, QuestionList), answerQuestionList(QuestionList, Answer).







ask_question(Question, Answer) :- askQuestion(Question, Answer).
