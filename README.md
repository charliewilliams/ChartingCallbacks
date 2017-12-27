	1.	Big long string
	2.	Tokenize all the words
	⁃	Store not just in a big row but as [Token: [Index]]
	3.	For each adjacent pair of tokens, look at all later occurrence indices to see if those tokens are grouped there too.
	⁃	If you find a second occurrence of pairing, create a new "grouped" token for all of these pair-occurrences
	⁃	Repeat this step until no more groups are created (i.e. adding a third, fourth, fifth word to the token)
	4.	Sort by token word count
	5.	Output json
