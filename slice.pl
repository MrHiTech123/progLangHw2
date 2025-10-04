equals(A, A).

listSliceEnd([Head | Tail], EndIndex, [ResultListHead | ResultListTail]) :- 
	FutureEndIndex is EndIndex - 1,
	equals(Head, ResultListHead),
	(
		equals(EndIndex, 0), equals(ResultListTail, []);
		not(equals(EndIndex, 0)), listSliceEnd(Tail, FutureEndIndex, ResultListTail)
	).

listSlice([Head | Tail], StartIndex, EndIndex, ResultList) :- 
	FutureStartIndex is StartIndex - 1,
	FutureEndIndex is EndIndex - 1,
	(
		equals(StartIndex, 0), listSliceEnd([Head | Tail], FutureEndIndex, ResultList);
		not(equals(StartIndex, 0)), listSlice(Tail, FutureStartIndex, FutureEndIndex, ResultList)
	).
	
	



