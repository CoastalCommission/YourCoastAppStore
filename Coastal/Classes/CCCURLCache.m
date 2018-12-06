//
//  CCCURLCache.m
//  Coastal
//
//  Created by Oliver White on 1/29/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <objc/runtime.h>
#import "CCCURLCache.h"

static NSString * const kCCCURLCacheCachedAt = @"CCCURLCacheCachedAt";

@interface NSURL (CCCURLCache)

@property (nonatomic, copy) NSDate *ccc_cachedAt;

@end

@implementation NSURL (CCCURLCache)

- (NSDate *)ccc_cachedAt
{
    return objc_getAssociatedObject(self, &kCCCURLCacheCachedAt);
}

- (void)setCcc_cachedAt:(NSDate *)ccc_cachedAt
{
    return objc_setAssociatedObject(self, &kCCCURLCacheCachedAt, ccc_cachedAt, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation CCCURLCache
{
    NSMutableDictionary *_cache;
}

+ (instancetype)sharedCache
{
    static id sharedCache = nil;

    static dispatch_once_t token;
    dispatch_once(&token, ^{

        sharedCache = [[[self class] alloc] init];
    });

    return sharedCache;
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
    NSDate *date = ((NSURL *)key).ccc_cachedAt;
    if (date && [date timeIntervalSinceNow] > -30.0)
    {
        return _cache[key];
    }

    [_cache removeObjectForKey:key];

    return nil;
}

- (void)setObject:(id)object
forKeyedSubscript:(id <NSCopying>)key
{
    if (object)
    {
        _cache[key] = object;
        ((NSURL *)key).ccc_cachedAt = [NSDate date];
    }
    else
    {
        [_cache removeObjectForKey:key];
    }
}

#pragma mark - NSObject

- (id)init
{
    if ((self = [super init]))
    {
        _cache = [[NSMutableDictionary alloc] init];
    }

    return self;
}

@end
