//
//  CCCSearchAccessPoint.m
//  Coastal
//
//  Created by Dai Hovey on 27/11/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCSearchAccessPoint.h"

@implementation CCCSearchAccessPoint

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.accessPoint = [aDecoder decodeObjectForKey:@"accessPoint"];
        self.placemark = [aDecoder decodeObjectForKey:@"placemark"];
        self.dateAdded = [aDecoder decodeObjectForKey:@"dateAdded"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.accessPoint forKey:@"accessPoint"];
    [aCoder encodeObject:self.placemark forKey:@"placemark"];
    [aCoder encodeObject:self.dateAdded forKey:@"dateAdded"];
}

@end