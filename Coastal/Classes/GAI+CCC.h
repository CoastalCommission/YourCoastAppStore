//
//  GAI+CCC.h
//  Coastal
//
//  Created by Malcolm on 2014-04-29.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "GAI.h"

extern NSString * const CCCScreenMap;
extern NSString * const CCCScreenList;
extern NSString * const CCCScreenFilter;
extern NSString * const CCCScreenAccessPoint;
extern NSString * const CCCScreenSearch;
extern NSString * const CCCScreenReport;

@interface GAI (CCC)

+ (void)ccc_startSession;
+ (void)ccc_endSession;

+ (void)ccc_sendScreen:(NSString *)screenName;

+ (void)ccc_sendEvent:(NSString *)category
               action:(NSString *)action
                label:(NSString *)label
                value:(NSNumber *)value;

@end
