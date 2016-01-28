//
//  LoginLaunch.h
//  SpaceName
//
//  Created by Tim Sheridan on 28/01/2016.
//  Copyright © 2016 Tim Sheridan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginLaunch : NSObject

+ (BOOL)getAppLaunches:(NSString *)app;
+ (void)setAppLaunches:(NSString *)app to:(BOOL)setting;
+ (void)toggleAppLaunches:(NSString *)app;

@end
