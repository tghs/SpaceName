//
//  TSAPI.m
//  SpaceName
//
//  Created by Tim Sheridan on 27/01/2016.
//  Copyright © 2016 Tim Sheridan. All rights reserved.
//

#import "TSAPI.h"

#include "TSLib.h"
#include <string.h>

@implementation TSAPI

+ (BOOL)available {
	const char *apiVersion = tsapi_apiVersion();
	BOOL ret = (strcmp("", apiVersion) != 0);
	tsapi_freeString(apiVersion);
	return ret;
}

+ (NSString *)currentSpaceName {
	struct tsapi_displays *displays = tsapi_displayList();
	CGDirectDisplayID display_id = displays->displays[0].displayId;
	unsigned space_id = tsapi_currentSpaceNumberOnDisplay(display_id);
	const char *space_name = tsapi_spaceNameForSpaceNumberOnDisplay(space_id, display_id);
	NSString *ret = [NSString stringWithCString:space_name encoding:NSUTF8StringEncoding];
	tsapi_freeString(space_name);
	return ret;
}

@end
