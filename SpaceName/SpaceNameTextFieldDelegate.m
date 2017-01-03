//
//  SpaceNameTextFieldDelegate.m
//  SpaceName
//
//  Created by Tim Sheridan on 23/01/2016.
//  Copyright © 2016 Tim Sheridan. All rights reserved.
//

#import "SpaceNameTextFieldDelegate.h"

@implementation SpaceNameTextFieldDelegate

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
	if ((commandSelector == @selector(complete:)) || // Clicking outside of app to abort
	    (commandSelector == @selector(cancel:))) {   // Pressing escape to abort
		[self.appDelegate cancelEdit];
		return YES;
	} else if (commandSelector == @selector(cancel:)) {
		[self.appDelegate cancelEdit];
		return YES;
	}
	return NO;
}

@end
