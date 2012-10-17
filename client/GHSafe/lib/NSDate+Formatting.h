//
//  NSDate+Formatting.h
//  GetHomeSafe
//
//  Created by Nan Zhong on 11-06-16.
//  Copyright 2011 GetHomeSafe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (NSDate_Formatting)

+ (NSString *)datUTCString;
+ (NSDate *)dateWithUTCString:(NSString *)dateString;

- (NSString *)dateLocalString;
- (NSString *)dateUTCString;

@end
