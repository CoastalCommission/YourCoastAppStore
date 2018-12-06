//
//  CCCModelContext.h
//  Coastal
//
//  Created by Dai Hovey on 27/11/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCCSearchAccessPoint;

@interface CCCModelContext : NSObject

@property (nonatomic, readonly) NSArray *objects;

+ (instancetype)shared;

- (void)updateContext:(NSMutableArray *)objects;

@end
