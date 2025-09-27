equals(A, A).

popHeadOff([Head | Tail], Head, Tail).

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

number([Head | Tail], Head, Tail) :- integer(Head).

verbPhraseAllowsForPlayers(Query, Plurality, [AllowVerbThatGameDoes | VerbPhraseTail], S) :-
	matchPluralityToAllowPlurality(Plurality, AllowVerbThatGameDoes),
	word(for, VerbPhraseTail, NumberAndPlayersLiteral),
	number(NumberAndPlayersLiteral, NumberOfPlayers, PlayersLiteral),
	word(players, PlayersLiteral, S),
	equals(Query, [allow_players, NumberOfPlayers]).
	
	
verbPhraseTakesMinutes(Query, Plurality, [TakeVerbThatGameDoes | VerbPhraseTail], S) :-
	matchPluralityToTakePlurality(Plurality, TakeVerbThatGameDoes),
	word(less, VerbPhraseTail, VerbPhraseTailAfterLess),
	word(than, VerbPhraseTailAfterLess, VerbPhraseTailAfterThan),
	number(VerbPhraseTailAfterThan, NumberOfMinutes, MinutesLiteral),
	word(minutes, MinutesLiteral, S),
	equals(Query, [time_check, NumberOfMinutes]).

verbPhrase(Query, Plurality, [VerbThatGameDoes | VerbPhraseTail], S) :-
	verbPhraseAllowsForPlayers(Query, Plurality, [VerbThatGameDoes | VerbPhraseTail], S);
	verbPhraseTakesMinutes(Query, Plurality, [VerbThatGameDoes | VerbPhraseTail], S).



question(Query, Plurality, S0, S) :- 
	word(which, S0, S1),
	nounPhrase(Plurality, [game, games], S1, S2),
	verbPhrase(Query, Plurality, S2, S).