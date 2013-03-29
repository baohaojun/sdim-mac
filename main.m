
#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

#include <stdlib.h>
#include <unistd.h>

const NSString* kConnectionName = @"SdimMac_1_Connection";

IMKServer*			server;
IMKCandidates*		candidates = nil;


int main(int argc, char *argv[])
{

    close(1);
    close(2);

    char buffer[1024] = {0};
    snprintf(buffer, sizeof buffer, "%s/.xsession-errors", getenv("HOME"));

    int fd = open(buffer, O_APPEND|O_WRONLY);
    if (fd >= 0) {
	dup2(fd, 1);
	dup2(fd, 2);
    }
    printf("hello world\n");
    fflush(stdout);
    
    NSString*       identifier;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    identifier = [[NSBundle mainBundle] bundleIdentifier];
    server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
	
	[NSBundle loadNibNamed:@"MainMenu" owner:[NSApplication sharedApplication]];
	
	candidates = [[IMKCandidates alloc] initWithServer:server panelType:kIMKSingleColumnScrollingCandidatePanel];
	
	[[NSApplication sharedApplication] run];
	
	[server release];
	[candidates release];
	
    [pool release];
    return 0;
}
