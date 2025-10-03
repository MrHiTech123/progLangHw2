equals(A, A).
implies(P, Q) :- Q, not(P).

exclusiveOr(P, Q) :- 
	P, not(Q);
	Q, not(P).

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

pathRecur(List1, List2, Depth) :-
	equals(List1, List2);
	
	length(List1, List1Length),
	Depth < List1Length,
	DepthPlusOne is Depth + 1,
	transform(List1, TransformedList1),
	pathRecur(TransformedList1, List2, DepthPlusOne).

pathSecond(List1, List2) :- pathRecur(List1, List2, 0).

path([List1Head | List1Tail], [List2Head | List2Tail]) :-
	equals(List1Head, List2Head),
	pathSecond(List1Tail, List2Tail).



pathUnique(Paths, List1, EndPaths) :-
	path(List1, List2),
	length(List1, List1Length),
	MinusOne is List1Length - 1,
	factorial(MinusOne, Permutations),
	exclusiveOr(
		(
			not(contains(Paths, List2)),
			pathUnique([List2 | Paths], List1, EndPaths)
		),
		(
			length(Paths, PathsLength),
			equals(PathsLength, Permutations),
			equals(Paths, EndPaths)
		)
	).

% Takes a list (EndPaths) and writes each element in it on a separate line.
writeEach(EndPaths) :- 
	equals(EndPaths, [EndPathsHead | EndPathsTail]), write(EndPathsHead), nl, writeEach(EndPathsTail); 
	
	equals(EndPaths, []).

write_all(List1) :-
	pathUnique([], List1, EndPaths),
	writeEach(EndPaths),
	write("TERMINATED"), %This printed automatically for me at some point and I have no idea why. In the final version I had to print it manually
	nl,
	halt(0).













