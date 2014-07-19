// -*- mode: objc -*-

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

const NSString* kDecimalMode = @"com.apple.inputmethod.sdim";

@interface SdimMacController : IMKInputController {
		
    NSMutableString*				_composedBuffer;
    NSMutableString*				_originalBuffer;
    NSInteger                                   _insertionIndex;
    BOOL                                        _didConvert;
    id						_currentClient;
}

-(NSMutableString*)composedBuffer;
-(void)setComposedBuffer:(NSString*)string;

-(void)commitStr:(NSString*)str;

-(void)setPreEditStr:(NSString*)string;
-(NSString*)preEditStr;

@end
