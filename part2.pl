equals(A, A).
implies(P, Q) :- Q, not(P).

transform([Head | [Second | Tail]], [Second | [Head | Tail]]).
transform([Head | Tail], [TransformedHead | TransformedTail]) :- equals(Head, TransformedHead), transform(Tail, TransformedTail).

factorial(0, 1).
factorial(Arg, Answer) :- 
	Arg > 0, 
	MinusOne is Arg - 1, 
	factorial(MinusOne, AnswerMinusOne),
	Answer is Arg * AnswerMinusOne.

contains([Head | Tail], Element) :- 
	equals(Head, Element);
	contains(Tail, Element).

path(List1, List2) :-
	equals(List1, List2);
	transform(List1, TransformedList1), path(TransformedList1, List2).



pathUnique(Paths, List1, EndPaths).
	length(Paths, PathsLength),
	length(List1, List1Length),
	factorial(List1Length, TotalPermutations),
	implies(
		not(equals(PathsLength, TotalPermutations)),
		(
			path(List1, FoundPath),
			not(contains(Paths, FoundPath)),
			pathUnique([FoundPath | Paths], List1, EndPaths)
		)
	),
	implies(equals(PathsLength, TotalPermutations), 
		(
			equals(EndPaths, Paths)
		)
	).















