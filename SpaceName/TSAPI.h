//
//  TSAPI.h
//  SpaceName
//
//  Created by Tim Sheridan on 27/01/2016.
//  Copyright © 2016 Tim Sheridan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSAPI : NSObject

+ (BOOL)available;
+ (NSString *)currentSpaceName;

@end
