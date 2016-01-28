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

@end
