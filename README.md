CoreParse
=========

CoreParse is a parsing library for OS X.  It supports a wide range of grammars thanks to its shift/reduce parsing schemes.  Currently CoreParse supports SLR, LR(1) and LALR(1) parsers.

For full documentation see http://beelsebob.github.com/CoreParse.

Parsing Guide
=============

CoreParse is a powerful framework for tokenising and parsing.  This document explains how to create a tokeniser and parser from scratch, and how to use those parsers to create your model data structures for you.  We will follow the same example throughout this document.  This will deal with parsing a simple numerical expression and computing the result.

Tokenisation
------------

CoreParse's tokenisation class is CPTokeniser.  To specify how tokens are constructed you must add *token recognisers* in order of precidence to the tokeniser.

Our example language will involve several symbols, numbers, whitespace, and comments.  We add these to the tokeniser:

    CPTokeniser *tokeniser = [[[CPTokeniser alloc] init] autorelease];
    [tokeniser addTokenRecogniser:[CPNumberRecogniser numberRecogniser]];
    [tokeniser addTokenRecogniser:[CPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [tokeniser addTokenRecogniser:[CPQuotedRecogniser quotedRecogniserWithStartQuote:@"/*" endQuote:@"*/" name:@"Comment"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"+"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"-"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"*"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"/"]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@"("]];
    [tokeniser addTokenRecogniser:[CPKeywordRecogniser recogniserForKeyword:@")"]];

Note that the comment tokeniser is added before the keyword recogniser for the divide symbol.  This gives it higher precidence, and means that the first slash of a comment will not be recognised as a division.

Next, we add ourself as a delegate to the tokeniser.  We implement the tokeniser delegate methods in such a way that whitespace tokens and comments, although consumed, will not appear in the tokeniser's output:

    - (BOOL)tokeniser:(CPTokeniser *)tokeniser shouldConsumeToken:(CPToken *)token
    {
        return YES;
    }
    
    - (NSArray *)tokeniser:(CPTokeniser *)tokeniser willProduceToken:(CPToken *)token
    {
        if ([token isKindOfClass:[CPWhiteSpaceToken class]] || [[token name] isEqualToString:@"Comment"])
        {
            return [NSArray array];
        }
        return [NSArray arrayWithObject:token];
    }

We can now invoke our tokeniser.

    CPTokenStream *tokenStream = [tokeniser tokenise:@"5 + (2.0 / 5.0 + 9) * 8"];

Parsing
-------

We construct parsers by specifying their grammar.  We can construct a grammar simply using a simple BNF like language:

    NSString *expressionGrammar =
        @"0 e ::= <t>;"
        @"1 e ::= <e> <a> <t>;"
        @"2 t ::= <f>;"
        @"3 t ::= <t> <m> <f>;"
        @"4 f ::= \"Number\";"
        @"5 f ::= \"(\" <e> \")\";"
        @"6 a ::= \"+\" | \"-\";"
        @"7 m ::= \"*\" | \"/\";";
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"e" backusNaurForm:expressionGrammar];

The numbers on each line indicate a "tag" which will be used to recognise the rules later on.

Now that we have our grammar we may construct a parser from it, and set ourself as the delegate:

    CPParser *parser = [CPLALR1Parser parserWithGrammar:grammar];
    [parser setDelegate:self];

We implement the delegate method.  Note that instead of returning a tree structure at each stage, we collapse the syntax tree into the resulting number.  The result of doing this is that when we parse, the output of the CPParser is not a syntax tree, but instead the value of the computed expression:

    - (id)parser:(CPParser *)parser didProduceSyntaxTree:(CPSyntaxTree *)syntaxTree
    {
        CPRule *r = [syntaxTree rule];
        NSArray *c = [syntaxTree children];
        
        switch ([r tag])
        {
            case 0:
            case 2:
                return [c objectAtIndex:0];
            case 1:
            {
                NSString *operator = [[c objectAtIndex:1] keyword];
                if ([operator isEqualToString:@"+"])
                {
                    return [NSNumber numberWithInt:[[c objectAtIndex:0] doubleValue] + [[c objectAtIndex:2] doubleValue]];
                }
                else
                {
                    return [NSNumber numberWithInt:[[c objectAtIndex:0] doubleValue] - [[c objectAtIndex:2] doubleValue]];
                }
            }
            case 3:
            {
                NSString *operator = [[c objectAtIndex:1] keyword];
                if ([operator isEqualToString:@"*"])
                {
                    return [NSNumber numberWithInt:[[c objectAtIndex:0] doubleValue] * [[c objectAtIndex:2] doubleValue]];
                }
                else
                {
                    return [NSNumber numberWithInt:[[c objectAtIndex:0] doubleValue] / [[c objectAtIndex:2] doubleValue]];
                }
            }
            case 4:
                return [(CPNumberToken *)[c objectAtIndex:0] number];
            case 5:
                return [c objectAtIndex:1];
            default:
                return syntaxTree;
        }
    }

We can now parse the token stream we produced earlier:

    NSLog(@"%@", [parser parse:tokenStream]);

Which outputs:

    80.2
