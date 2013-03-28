#import "NumberInputController.h"
#import "ConversionEngine.h"
#import "NumberInputApplicationDelegate.h"


@implementation NumberInputController

-(BOOL)inputText:(NSString*)string client:(id)sender
{
		BOOL					inputHandled = NO;
		NSScanner*				scanner = [NSScanner scannerWithString:string];
		NSDecimal				decimalValue;
		BOOL					isDecimal = [scanner scanDecimal:&decimalValue];

		if ( isDecimal ) {
			[self originalBufferAppend:string client:sender];
			inputHandled = YES;
		}
		else {
			inputHandled = [self convert:string client:sender];
		}
        return inputHandled;
}

-(void)commitComposition:(id)sender 
{
	NSString*		text = [self composedBuffer];

	if ( text == nil || [text length] == 0 ) {
		text = [self originalBuffer];
	}
	
	[sender insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
	
	[self setComposedBuffer:@""];
	[self setOriginalBuffer:@""];
	_insertionIndex = 0;
	_didConvert = NO;
}

-(NSMutableString*)composedBuffer;
{
	if ( _composedBuffer == nil ) {
		_composedBuffer = [[NSMutableString alloc] init];
	}
	return _composedBuffer;
}

-(void)setComposedBuffer:(NSString*)string
{
	NSMutableString*		buffer = [self composedBuffer];
	[buffer setString:string];
}


-(NSMutableString*)originalBuffer
{
	if ( _originalBuffer == nil ) {
		_originalBuffer = [[NSMutableString alloc] init];
	}
	return _originalBuffer;
}

-(void)originalBufferAppend:(NSString*)string client:(id)sender
{
	NSMutableString*		buffer = [self originalBuffer];
	[buffer appendString: string];
	_insertionIndex++;
	[sender setMarkedText:buffer selectionRange:NSMakeRange(0, [buffer length]) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

-(void)setOriginalBuffer:(NSString*)string
{
	NSMutableString*		buffer = [self originalBuffer];
	[buffer setString:string];
}

-(BOOL)didCommandBySelector:(SEL)aSelector client:(id)sender
{
    if ([self respondsToSelector:aSelector]) {
		
		NSString*		bufferedText = [self originalBuffer];
		
		if ( bufferedText && [bufferedText length] > 0 ) {
			if (aSelector == @selector(insertNewline:) ||
				aSelector == @selector(deleteBackward:) ) {
					[self performSelector:aSelector withObject:sender];
					return YES; 
			}
		}
		
    }
	
	return NO;
}

- (void)insertNewline:(id)sender
{
	[self commitComposition:sender];
	
}

- (void)deleteBackward:(id)sender
{
	NSMutableString*		originalText = [self originalBuffer];
	NSString*				convertedString;

	if ( _insertionIndex > 0 && _insertionIndex <= [originalText length] ) {
		--_insertionIndex;
		[originalText deleteCharactersInRange:NSMakeRange(_insertionIndex,1)];
		convertedString = [[[NSApp delegate] conversionEngine] convert:originalText];
		[self setComposedBuffer:convertedString];
		[sender setMarkedText:convertedString selectionRange:NSMakeRange(_insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
	}
}

- (BOOL)convert:(NSString*)trigger client:(id)sender
{
	NSString*				originalText = [self originalBuffer];
	NSString*				convertedString = [self composedBuffer];
	BOOL					handled = NO;
	
	if ( _didConvert && convertedString && [convertedString length] > 0  ) {

			extern IMKCandidates*		candidates;
			if ( candidates ) {
			
				_currentClient = sender;
				[candidates updateCandidates];
				[candidates show:kIMKLocateCandidatesBelowHint];
				
				
			}
			else {
			
				NSString*		completeString = [convertedString stringByAppendingString:trigger];
				
				[sender insertText:completeString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
				
				[self setComposedBuffer:@""];
				[self setOriginalBuffer:@""];
				_insertionIndex = 0;
				_didConvert = NO;
				handled = YES;
			}

	}
	else if ( originalText && [originalText length] > 0 ) {
		
			convertedString = [[[NSApp delegate] conversionEngine] convert:originalText];
			[self setComposedBuffer:convertedString];
			
			if ( [trigger isEqual: @" "] ) {
				[sender setMarkedText:convertedString selectionRange:NSMakeRange(_insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
				_didConvert = YES;
			}
			else {
				[self commitComposition:sender];
				[sender insertText:trigger replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
			}
			handled = YES;
	}
	return handled;
}

-(void)setValue:(id)value forTag:(unsigned long)tag client:(id)sender
{
	NSString*		newModeString = [(NSString*)value retain];
	NSNumberFormatterStyle	currentMode = [[[NSApp delegate] conversionEngine] conversionMode];
	NSNumberFormatterStyle newMode;
	
	if ( [newModeString isEqual:kDecimalMode] ) {
		newMode = NSNumberFormatterDecimalStyle;
	}
	else if ( [newModeString isEqual:kCurrencyMode] ) {
		newMode = NSNumberFormatterCurrencyStyle;
	}
	else if ( [newModeString isEqual:kPercentMode] ) {
		newMode = NSNumberFormatterPercentStyle;
	}
	else if ( [newModeString isEqual:kScientificMode] ) {
		newMode = NSNumberFormatterScientificStyle;
	}
	else if ( [newModeString isEqual:kSpelloutMode] ) {
		newMode = NSNumberFormatterSpellOutStyle;
	}
	
	if ( currentMode != newMode ) {
		[[[NSApp delegate] conversionEngine] setConversionMode:newMode];
	}
}

- (NSArray*)candidates:(id)sender
{
    NSMutableArray*			theCandidates = [NSMutableArray array];
	ConversionEngine*		engine = [[NSApp delegate] conversionEngine];
	NSNumberFormatterStyle	currentStyle = [ engine conversionMode];
	NSInteger				index;
	NSString*				originalString = [self originalBuffer];
    

	for ( index = NSNumberFormatterDecimalStyle; index < NSNumberFormatterSpellOutStyle+1; index++ ) {
		[engine setConversionMode:index];
		[theCandidates addObject:[engine convert:originalString]];
	}
	[engine setConversionMode:currentStyle];
	return theCandidates;
	
}

- (void)candidateSelectionChanged:(NSAttributedString*)candidateString
{
	[_currentClient setMarkedText:[candidateString string] selectionRange:NSMakeRange(_insertionIndex, 0) replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
	_insertionIndex = [candidateString length];
}

- (void)candidateSelected:(NSAttributedString*)candidateString
{
	[self setComposedBuffer:[candidateString string]];
	[self commitComposition:_currentClient];
}


-(void)dealloc 
{
	[_composedBuffer release];
	[_originalBuffer release];
	[super dealloc];
}

 
@end
