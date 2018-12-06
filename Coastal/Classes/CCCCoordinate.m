//
//  CCCCoordinate.m
//  Coastal
//
//  Created by Malcolm on 2014-05-16.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCCoordinate.h"

@interface CCCCoordinate ()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation CCCCoordinate
{
    NSUInteger _hash;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self)
    {
        self.coordinate = coordinate;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;

    NSInteger latitude = (NSInteger)(coordinate.latitude * 10000);
    NSInteger longitude = (NSInteger)(coordinate.longitude * 10000);

    _hash = latitude ^ longitude;
}

- (NSUInteger)hash
{
    return _hash;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]] == NO)
    {
        return NO;
    }

    CLLocationCoordinate2D otherCoordinate = [object coordinate];

    static double const epsilon = 0.0001;
    if (ABS(otherCoordinate.latitude - self.coordinate.latitude) > epsilon)
    {
        return NO;
    }

    if (ABS(otherCoordinate.longitude - self.coordinate.longitude) > epsilon)
    {
        return NO;
    }

    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] initWithCoordinate:self.coordinate];

    return copy;
}

@end
