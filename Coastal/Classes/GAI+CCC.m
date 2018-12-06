//
//  GAI+CCC.m
//  Coastal
//
//  Created by Malcolm on 2014-04-29.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "GAI+CCC.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

NSString * const CCCScreenMap = @"map";
NSString * const CCCScreenList = @"list";
NSString * const CCCScreenFilter = @"filter";
NSString * const CCCScreenAccessPoint = @"access point";
NSString * const CCCScreenSearch = @"search";
NSString * const CCCScreenReport = @"report a problem";

@implementation GAI (CCC)

+ (void)ccc_startSession
{
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAISessionControl
           value:@"start"];
}

+ (void)ccc_endSession
{
    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAISessionControl
           value:@"end"];
}

+ (void)ccc_sendScreen:(NSString *)screenName
{
#ifdef DEBUG
    NSLog(@"screen: %@", screenName);
#endif

    id <GAITracker> tracker = [[self sharedInstance] defaultTracker];

    [tracker set:kGAIScreenName
           value:screenName];

    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

+ (void)ccc_sendEvent:(NSString *)category
               action:(NSString *)action
                label:(NSString *)label
                value:(NSNumber *)value
{
#ifdef DEBUG
    NSLog(@"event: %@, %@, %@, %@", category, action, label, value);
#endif

    id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:value] build]];
}

@end
