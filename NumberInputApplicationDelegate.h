// -*- mode: objc -*-

#import <Cocoa/Cocoa.h>
#import "ConversionEngine.h"

@interface NumberInputApplicationDelegate : NSObject {
	IBOutlet ConversionEngine*			_conversionEngine;
}

-(ConversionEngine*)conversionEngine;

@end
