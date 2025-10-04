%A = A (Used so I do not have to rename variables)
equals(A, A).
%Implies (I do not think I used this)
implies(P, Q) :- Q, not(P).
%XOR
exclusiveOr(P, Q) :- 
	P, not(Q);
	Q, not(P).

%Either swap the current head and second element in the list, or leave them the same and swap something in one of the tails.
%This results in a swap happening somewhere.
transform([Head | [Second | Tail]], [Second | [Head | Tail]]).
transform([Head | Tail], [TransformedHead | TransformedTail]) :- equals(Head, TransformedHead), transform(Tail, TransformedTail).

%Sumtorial, finds sum(i = 0, Arg) and returns it in Answer.
sumtorial(0, 0).
sumtorial(Arg, Answer) :-
	Arg > 0,
	MinusOne is Arg - 1,
	sumtorial(MinusOne, AnswerMinusOne),
	Answer is Arg + AnswerMinusOne.

%Factorial of Arg = Answer
factorial(0, 1).
factorial(Arg, Answer) :- 
	Arg > 0, 
	MinusOne is Arg - 1, 
	factorial(MinusOne, AnswerMinusOne),
	Answer is Arg * AnswerMinusOne.

%Check if the list contains Element
contains([Head | Tail], Element) :- 
	equals(Head, Element);
	contains(Tail, Element).

%Check if one of the tails of the seating arrangements has tails to the other one.
pathRecur(List1, List2, Depth) :-
	equals(List1, List2);
	
	length(List1, List1Length),
	sumtorial(List1Length, MaxDepth),
	Depth < MaxDepth,
	DepthPlusOne is Depth + 1,
	transform(List1, TransformedList1),
	pathRecur(TransformedList1, List2, DepthPlusOne).

%Non-recursive function, initializes the Depth variable
pathSecond(List1, List2) :- pathRecur(List1, List2, 0).

%Find if there is a path between List1 and List2, or find all lists List2 such that a path exists from List1.
path([List1Head | List1Tail], [List2Head | List2Tail]) :-
	equals(List1Head, List2Head),
	pathSecond(List1Tail, List2Tail).


%Find all unique paths from one list
pathUnique(Paths, List1, EndPaths) :-
	path(List1, List2),
	length(List1, List1Length),
	MinusOne is List1Length - 1,
	factorial(MinusOne, Permutations), %Permutations = (List1Length - 1)!
	exclusiveOr(
		(
			not(contains(Paths, List2)), %Either the list of answers does not contain List2, so it gets added, or...
			pathUnique([List2 | Paths], List1, EndPaths)
		),
		(
			%...All the Permutations have been found (because Paths is unique and has (List1Length - 1)! values),
			% the list returns as EndPaths.
			length(Paths, PathsLength),
			equals(PathsLength, Permutations),
			equals(Paths, EndPaths)
		)
	).

% Takes a list (EndPaths) and writes each element in it on a separate line.
writeEach(EndPaths) :- 
	equals(EndPaths, [EndPathsHead | EndPathsTail]), write(EndPathsHead), nl, writeEach(EndPathsTail); 
	
	equals(EndPaths, []).

% Write all paths from one program.
write_all(List1) :-
	pathUnique([], List1, EndPaths),
	writeEach(EndPaths),
	write("TERMINATED"), %This printed automatically for me at some point and I have no idea why. In the final version I had to print it manually
	nl,
	halt(0). %Just terminate after one iteration, we have already printed out all the answers.













