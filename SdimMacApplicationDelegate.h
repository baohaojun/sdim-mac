// -*- mode: objc -*-

#import <Cocoa/Cocoa.h>
#import "ConversionEngine.h"

@interface SdimMacApplicationDelegate : NSObject {
	IBOutlet ConversionEngine*			_conversionEngine;
}

-(ConversionEngine*)conversionEngine;

@end
