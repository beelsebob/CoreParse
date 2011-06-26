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
        @"Expression ::= <Term>     | <Expression> <AddOp> <Term>;"
        @"Term       ::= <Factor>   | <Term>       <MulOp> <Factor>;"
        @"Factor     ::= \"Number\" | \"(\" <Expression> \")\";"
        @"AddOp      ::= \"+\" | \"-\";"
        @"MulOp      ::= \"*\" | \"/\";";
    CPGrammar *grammar = [CPGrammar grammarWithStart:@"Expression" backusNaurForm:expressionGrammar];
    CPParser *parser = [CPLALR1Parser parserWithGrammar:grammar];
    [parser setDelegate:self];

When a rule is matched by the parser, the `initWithSyntaxTree:` method will be called on a new instance of the apropriate class.  If no such class exists the parser delegate's `parser:didProduceSyntaxTree:` method is called.  To deal with this cleanly, we implement 3 classes: Expression; Term; and Factor.  AddOp and MulOp non-terminals are dealt with by the parser delegate.  Here we see the initWithSyntaxTree: method for the Expression class, these methods are similar for Term and Factor:
    
    - (id)initWithSyntaxTree:(CPSyntaxTree *)syntaxTree
    {
        self = [self init];
        
        if (nil != self)
        {
            NSArray *components = [syntaxTree children];
            if ([components count] == 1)
            {
                [self setValue:[(Term *)[components objectAtIndex:0] value]];
            }
            else
            {
                NSString *op = [components objectAtIndex:1];
                if ([op isEqualToString:@"+"])
                {
                    [self setValue:[(Expression *)[components objectAtIndex:0] value] + [(Term *)[components objectAtIndex:2] value]];
                }
                else
                {
                    [self setValue:[(Expression *)[components objectAtIndex:0] value] - [(Term *)[components objectAtIndex:2] value]];
                }
            }
        }
        
        return self;
    }

We must also implement the delegate's method for dealing with AddOps and MulOps:

    - (id)parser:(CPParser *)parser didProduceSyntaxTree:(CPSyntaxTree *)syntaxTree
    {
        return [(CPQuotedToken *)[[syntaxTree children] objectAtIndex:0] content];
    }

We can now parse the token stream we produced earlier:

    NSLog(@"%@", [(Expression *)[parser parse:tokenStream] value]);

Which outputs:

    80.2
