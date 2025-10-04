%A = A (Used so I do not have to rename variables)
equals(A, A).

%Use two lists of the same length as a set of key-value pairs.
matchKeyToValue([KeysHead | KeysTail], [ValuesHead | ValuesTail], Key, Value) :-
	equals(KeysHead, Key), equals(ValuesHead, Value);
	matchKeyToValue(KeysTail, ValuesTail, Key, Value).

%Specific uses of the above function
matchGamePluralityToPlurality(GamePlurality, Plurality) :- 
	matchKeyToValue([game, games], [singular, plural], GamePlurality, Plurality).

matchPluralityToAllowPlurality(Plurality, AllowPlurality) :-
	matchKeyToValue([singular, plural], [allows, allow], Plurality, AllowPlurality).

matchPluralityToTakePlurality(Plurality, TakePlurality) :-
	matchKeyToValue([singular, plural], [takes, take], Plurality, TakePlurality).


%Get the current word or check if it is at the current list index.
word(WordBeingTested, [WordBeingTested | S], S).

%Confirm a noun phrase, parsing Plurality from it as well. We are searching for Needle (the first word in S), 
%in Haystack (a list of valid nouns).
nounPhrase(Plurality, [HaystackHead | HaystackTail], [Needle | RestOfEnteredList], RestOfEnteredList) :- 
	(
		equals(HaystackHead, Needle);
		nounPhrase(Plurality, HaystackTail, [Needle | RestOfEnteredList], RestOfEnteredList)
	),
	matchGamePluralityToPlurality(Needle, Plurality).
%Like word but requires it to also be a number.
number(Num, [Num | S], S) :- integer(Num).

%Return true and update the query type if the sentence is a valid allow_players search
verbPhraseAllowsForPlayers(Query, Plurality, [AllowVerbThatGameDoes | S0], S) :-
	matchPluralityToAllowPlurality(Plurality, AllowVerbThatGameDoes),
	word(for, S0, S1),
	number(NumberOfPlayers, S1, S2),
	word(players, S2, S),
	equals(Query, [allow_players, NumberOfPlayers]).
	
%Return true and update the query type if the sentence is a valid time_check search
verbPhraseTakesMinutes(Query, Plurality, [TakeVerbThatGameDoes | S0], S) :-
	matchPluralityToTakePlurality(Plurality, TakeVerbThatGameDoes),
	word(less, S0, S1),
	word(than, S1, S2),
	number(NumberOfMinutes, S2, S3),
	word(minutes, S3, S),
	equals(Query, [time_check, NumberOfMinutes]).

%Return true and update the query for either search type.
verbPhrase(Query, Plurality, [VerbThatGameDoes | VerbPhraseTail], S) :-
	verbPhraseAllowsForPlayers(Query, Plurality, [VerbThatGameDoes | VerbPhraseTail], S);
	verbPhraseTakesMinutes(Query, Plurality, [VerbThatGameDoes | VerbPhraseTail], S).


% Extract a query and plurality from a question.
question(Query, Plurality, S0, S) :- 
	word(which, S0, S1),
	nounPhrase(Plurality, [game, games], S1, S2),
	verbPhrase(Query, Plurality, S2, S).

% Answer a query
answerQuery([QueryType, Argument], Answer) :-
	equals(QueryType, time_check), game(Answer), playing_time(Answer, PlayingTime), PlayingTime < Argument;
	equals(QueryType, allow_players), game(Answer), min_players(Answer, MinPlayers), max_players(Answer, MaxPlayers), (MinPlayers =< Argument), (MaxPlayers >= Argument).

% Get an answer from a tokenized question, or QuestionList.
answerQuestionList(QuestionList, Answer) :-
	question(Query, Plurality, QuestionList, []),
	(equals(Plurality, singular); equals(Plurality, plural)),
	answerQuery(Query, Answer).

%Pop an element from a list at a certain index, return the element popped and the resultant list.
listPop([Head | Tail], Index, ResultElement, [ResultListHead | ResultListTail]) :-
	equals(Index, 0), equals(Tail, [ResultListHead | ResultListTail]), equals(ResultElement, Head);
	not(equals(Index, 0)), MinusOne is Index - 1, equals(ResultListHead, Head), listPop(Tail, MinusOne, ResultElement, ResultListTail).

%Insert an element into a list at a certain index, return the resultant list.
listInsert([Head | Tail], Index, InsertedElement, [ResultListHead | ResultListTail]) :-
	equals(Index, 0), equals([Head | Tail], ResultListTail), equals(ResultListHead, InsertedElement);
	not(equals(Index, 0)), MinusOne is Index - 1, equals(ResultListHead, Head), listInsert(Tail, MinusOne, InsertedElement, ResultListTail).


% Preprocess a time check question, by tokenizing it and converting the argument string to an argument number.
preProcessQuestionTimeCheck(Question, QuestionList) :-
	atomic_list_concat(RawQuestionList, " ", Question),
	listPop(RawQuestionList, 5, AtomNumberOfMinutes, NumberPoppedList),
	atom_number(AtomNumberOfMinutes, NumberOfMinutes),
	listInsert(NumberPoppedList, 5, NumberOfMinutes, QuestionList).

% Preprocess a player check question, by tokenizing it and converting the argument string to an argument number.
preProcessQuestionPlayerCheck(Question, QuestionList) :- 
	atomic_list_concat(RawQuestionList, " ", Question),
	listPop(RawQuestionList, 4, AtomNumberOfPlayers, NumberPoppedList),
	atom_number(AtomNumberOfPlayers, NumberOfPlayers),
	listInsert(NumberPoppedList, 4, NumberOfPlayers, QuestionList).

% Preprocess either type of question.
preProcessQuestion(Question, QuestionList) :- 
	downcase_atom(Question, LowercaseQuestion),
	(
		preProcessQuestionTimeCheck(LowercaseQuestion, QuestionList);
		preProcessQuestionPlayerCheck(LowercaseQuestion, QuestionList)
	).

% Find an answer to a question
answerQuestionString(Question, Answer) :- 
	preProcessQuestion(Question, QuestionList), answerQuestionList(QuestionList, Answer).


% Get the plurality from a question string.
pluralityFromString(Question, Plurality) :- 
	preProcessQuestion(Question, QuestionList),
	question(Query, Plurality, QuestionList, []),
	not(equals(Query, [])).

% Given a bag of answers, get one answer or the none atom
singularAnswerFromBag(SortedBag, SingularAnswer) :-
	equals(SortedBag, []), equals(SingularAnswer, none);
	equals(SortedBag, [SingularAnswer | _]).

% Given a bag of answers, concatenate all answers together and return it, or return the none atom if there are no answers.
pluralAnswerFromSortedBag(ConcatedSortedBag, PluralAnswer) :- 
	equals(ConcatedSortedBag, ''), equals(PluralAnswer, none);
	not(equals(ConcatedSortedBag, '')), equals(ConcatedSortedBag, PluralAnswer).


% Ask a question and return the answer.
ask_question(Question, Answer) :- 
	pluralityFromString(Question, Plurality),
	findall(X, answerQuestionString(Question, X), Bag),
	msort(Bag, SortedBag),
	atomic_list_concat(SortedBag, ", ", ConcatedSortedBag),
	singularAnswerFromBag(SortedBag, SingularAnswer),
	pluralAnswerFromSortedBag(ConcatedSortedBag, PluralAnswer),
	(
		equals(Plurality, plural), equals(Answer, PluralAnswer);
		equals(Plurality, singular), equals(Answer, SingularAnswer)
	).
