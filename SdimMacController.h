// -*- mode: objc -*-

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

const NSString* kDecimalMode = @"com.apple.inputmethod.decimal";
const NSString* kCurrencyMode = @"com.apple.inputmethod.currency";
const NSString* kPercentMode = @"com.apple.inputmethod.percent";
const NSString* kScientificMode = @"com.apple.inputmethod.scientific";
const NSString* kSpelloutMode = @"com.apple.inputmethod.spellout";

@interface SdimMacController : IMKInputController {
		
    NSMutableString*				_composedBuffer;
    NSMutableString*				_originalBuffer;
    NSInteger                                   _insertionIndex;
    BOOL                                        _didConvert;
    id						_currentClient;
    NSString*                                   _preedit;
}

-(NSMutableString*)composedBuffer;
-(void)setComposedBuffer:(NSString*)string;

-(void)commitStr:(NSString*)str;
-(NSMutableString*)originalBuffer;
-(void)originalBufferAppend:(NSString*)string client:(id)sender;
-(void)setOriginalBuffer:(NSString*)string;

-(void)setPreEditStr:(NSString*)string;
-(NSString*)preEditStr;

- (void)showCandidates;

@end
