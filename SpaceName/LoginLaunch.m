//
//  LoginLaunch.m
//  SpaceName
//
//  Created by Tim Sheridan on 28/01/2016.
//  Copyright © 2016 Tim Sheridan. All rights reserved.
//

#import "LoginLaunch.h"

@implementation LoginLaunch

+ (BOOL)getAppLaunches:(NSString *)app {
	return NO;
}

+ (void)setAppLaunches:(NSString *)app to:(BOOL)setting {
}

+ (void)toggleAppLaunches:(NSString *)app {
	BOOL oldSetting = [LoginLaunch getAppLaunches:app];
	[LoginLaunch setAppLaunches:app to:(! oldSetting)];
}

@end
