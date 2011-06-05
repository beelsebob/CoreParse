CoreParse
=========

CoreParse is a parsing library for OS X.  It supports a wide range of grammars thanks to its shift/reduce parsing schemes.  Currently CoreParse supports SLR, LR(1) and LALR(1) parsers.

Parsing Guide
=============

CoreParse is a powerful framework for tokenising and parsing.  This document explains how to create a tokeniser and parser from scratch, and how to use those parsers to create your model data structures for you.  We will follow the same example throughout this document.  This will deal with parsing a simple numerical expression and computing the result.

Tokenisation
------------

CoreParse's tokenisation class is CPTokeniser.  To specify how tokens are constructed you must add *token recognisers* in order of precidence to the tokeniser.

Our example language will involve several symbols, numbers, whitespace, and comments.  We add these to the tokeniser:

<code>
CPTokeniser \*tokeniser = [[[CPTokeniser alloc] init] autorelease];<br />
[tokeniser addTokenRecogniser:[CPNumberRecogniser integerRecogniser]];<br />
[tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];<br />
[tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/\*" endQuote:@"\*/" name:@"Comment"]];<br />
[tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"+"]];<br />
[tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"-"]];<br />
[tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"\*"]];<br />
[tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"/"]];<br />
[tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"("]];<br />
[tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@")"]];<br />
[tokeniser setDelegate:[[[CPTestWhiteSpaceIgnoringDelegate alloc] init] autorelease]];<br />
</code>
