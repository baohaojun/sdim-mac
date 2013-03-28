// -*- mode: objc -*-


#import <Cocoa/Cocoa.h>



@interface ConversionEngine : NSObject {
		NSNumberFormatter*				  formatter;
        NSNumberFormatterStyle			  conversionMode;
}


-(NSString*)convert:(NSString*)string;


-(NSNumberFormatterStyle)conversionMode;

-(void)setConversionMode:(NSNumberFormatterStyle)mode;

@end
