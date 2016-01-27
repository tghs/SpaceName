//
//  AppDelegate.m
//  SpaceName
//
//  Created by Tim Sheridan on 08/01/2016.
//  Copyright © 2016 Tim Sheridan. All rights reserved.
//

#import "AppDelegate.h"

#import "SpaceNameTextFieldDelegate.h"
#import "TSLib.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

NSStatusItem *item;
NSView *oldView;
NSTextField *text;
SpaceNameTextFieldDelegate *spaceNameTextFieldDelegate;
NSMenu *menu;

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

- (void)doubleClick {
	// Set minimum width
	if ([text.stringValue length] < 8) {
		NSString *padding = @"";
		for (int i = 0; i < (8 - [text.stringValue length]); i++) {
			padding = [NSString stringWithFormat:@"%@%@", padding, @"m"];
		}
		
		NSString *tmp = text.stringValue;
		text.stringValue = [NSString stringWithFormat:@"%@%@", tmp, padding];
		[text sizeToFit];
		text.stringValue = tmp;
	} else {
		[text sizeToFit];
	}
	
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

- (void)cancelEdit {
	[self updateSpaceName];
	[self edited];
}

- (void)showPreferences {
	[self.window makeKeyAndOrderFront:self];
}

- (void)quit {
	[NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

- (void)menuSpaceChange: (NSMenuItem *)obj {
	struct tsapi_displays *displays = tsapi_displayList();
	CGDirectDisplayID display_id = displays->displays[0].displayId;
	unsigned space_id = tsapi_currentSpaceNumberOnDisplay(display_id);
	
	NSNumber *spaceNumber = obj.representedObject;
	tsapi_moveToSpaceOnDisplay([spaceNumber intValue], display_id);
	spaceChange(space_id, [spaceNumber intValue], display_id);
}

- (void)updateMenu {
	[menu removeAllItems];
	
	struct tsapi_displays *displays = tsapi_displayList();
	CGDirectDisplayID display_id = displays->displays[0].displayId;
	unsigned spaceCount = tsapi_numberOfSpacesOnDisplay(display_id);
	
	for (int i = 1; i <= spaceCount; i++) {
		const char *cSpaceName = tsapi_spaceNameForSpaceNumberOnDisplay(i, display_id);
		NSString *spaceName = [NSString stringWithCString:cSpaceName encoding:NSUTF8StringEncoding];
		NSMenuItem *item = [NSMenuItem new];
		item.title = spaceName;
		item.action = @selector(menuSpaceChange:);
		item.keyEquivalent = @"";
		NSNumber *spaceNumber = [NSNumber numberWithInt:i];
		item.representedObject = spaceNumber;
		[menu addItem:item];
		//[menu addItemWithTitle:spaceName action:@selector(menuSpaceChange:) keyEquivalent:@""];
	}
	
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItemWithTitle:@"Preferences" action:@selector(showPreferences) keyEquivalent:@""];
	[menu addItemWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""];
}

- (void)singleClick {
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		// Update menu
		[self updateMenu];
		usleep(300000);
		dispatch_async(dispatch_get_main_queue(), ^(void){
			// Only show the menu if not editing with a double-click
			if (item.view != text) {
				[item popUpStatusItemMenu:menu];
			}
		});
	});
}

- (void)updateSpaceName {
	NSString *spaceName = [AppDelegate currentSpaceName];
	item.button.title = spaceName;
	[text setStringValue: spaceName];
	item.doubleAction = @selector(doubleClick); // moved from initialization
	item.action = @selector(singleClick);
}

- (void)setupPreferences {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults registerDefaults:@{
		@"firstLaunch": @YES,
	}];
}

- (void)maybeFirstLaunch {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults boolForKey:@"firstLaunch"]) {
		// First launch
		[defaults setBool:NO forKey:@"firstLaunch"];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self setupPreferences];
	[self maybeFirstLaunch];

	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	
	item = [bar statusItemWithLength:NSVariableStatusItemLength];
	menu = [NSMenu new];
	
	text = [[NSTextField alloc] init];
	[text setEditable:TRUE];
	[text setAction:@selector(edited)];
	
	spaceNameTextFieldDelegate = [SpaceNameTextFieldDelegate new];
	spaceNameTextFieldDelegate.appDelegate = self;
	text.delegate = spaceNameTextFieldDelegate;
	
	this = self;
	tsapi_setSpaceWillChangeCallback(spaceChange);
	
	[self updateSpaceName];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (void)applicationWillResignActive:(NSNotification *)notification {
	[self cancelEdit];
}

@end
