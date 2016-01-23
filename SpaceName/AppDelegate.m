//
//  AppDelegate.m
//  SpaceName
//
//  Created by Tim Sheridan on 08/01/2016.
//  Copyright © 2016 Tim Sheridan. All rights reserved.
//

#import "AppDelegate.h"

#import "TSLib.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

NSStatusItem *item;
NSView *oldView;
NSTextField *text;

// self reference for C functions
id this;

+ (NSString *)currentSpaceName {
	struct tsapi_displays *displays = tsapi_displayList();
	CGDirectDisplayID display_id = displays->displays[0].displayId;
	unsigned space_id = tsapi_currentSpaceNumberOnDisplay(display_id);
	const char *space_name = tsapi_spaceNameForSpaceNumberOnDisplay(space_id, display_id);
	NSString *ret = [NSString stringWithCString:space_name encoding:NSUTF8StringEncoding];
	tsapi_freeString(space_name);
	return ret;
}

void spaceChange(unsigned int fromSpaceNumber, unsigned int toSpaceNumber, CGDirectDisplayID displayID) {
	[this updateSpaceName];
}

- (void)edit {
	[text sizeToFit];
	oldView = item.view;
	item.view = text;
	[text becomeFirstResponder];
	
	NSApplication *myApp = [NSApplication sharedApplication];
	[myApp activateIgnoringOtherApps:YES];
}

- (void)edited {
	NSString *newSpaceName = text.stringValue;
	
	struct tsapi_displays *displays = tsapi_displayList();
	CGDirectDisplayID display_id = displays->displays[0].displayId;
	unsigned space_id = tsapi_currentSpaceNumberOnDisplay(display_id);
	tsapi_spaceNameForSpaceNumberOnDisplay(space_id, display_id);
	
	const char *cSpaceName = [newSpaceName cStringUsingEncoding:NSUTF8StringEncoding];
	tsapi_setNameForSpaceOnDisplay(space_id, cSpaceName, display_id);
	
	item.view = oldView;
	[self updateSpaceName];
}

- (void)updateSpaceName {
	NSString *spaceName = [AppDelegate currentSpaceName];
	item.button.title = spaceName;
	[text setStringValue: spaceName];
	item.doubleAction = @selector(edit); // moved from initialization
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	
	item = [bar statusItemWithLength:NSVariableStatusItemLength];
	
	text = [[NSTextField alloc] init];
	[text setEditable:TRUE];
	[text setAction:@selector(edited)];
	
	this = self;
	tsapi_setSpaceWillChangeCallback(spaceChange);
	
	[self updateSpaceName];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (void)applicationWillResignActive:(NSNotification *)notification {
	[self updateSpaceName];
	[self edited];
}

@end
