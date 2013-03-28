
#import "ConversionEngine.h"


@implementation ConversionEngine

-(void)awakeFromNib
{
	[self setConversionMode:NSNumberFormatterDecimalStyle];
	
}

-(NSString*)convert:(NSString*)string
{
	
	
	
	if ( formatter == nil ) {
		[NSNumberFormatter setDefaultFormatterBehavior:NSNumberFormatterBehavior10_4];
		formatter = [[NSNumberFormatter alloc] init];		
	}
	[formatter setNumberStyle:NSNumberFormatterNoStyle];
	
	NSNumber*		number = [formatter numberFromString:string];
	
	[formatter setNumberStyle:[self conversionMode]];
	return [formatter stringFromNumber:number];
}

-(NSNumberFormatterStyle)conversionMode {
	return conversionMode;
}

-(void)setConversionMode:(NSNumberFormatterStyle)mode
{
	conversionMode = mode;
}

@end
