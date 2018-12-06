//
//  CCCModelContext.m
//  Coastal
//
//  Created by Dai Hovey on 27/11/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCModelContext.h"
#import "CCCSearchAccessPoint.h"
@import UIKit;

@interface CCCModelContext ()

@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) NSURL *URL;

@end

@implementation CCCModelContext

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static CCCModelContext *instance;
    dispatch_once(&onceToken, ^{ instance = [[[self class] alloc] init]; });
    return instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.URL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                        inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"searchItems.dat"];

        self.objects = [[NSArray alloc] init];

        NSData *data = [[NSData alloc] initWithContentsOfURL:self.URL
                                                     options:NSDataReadingUncached
                                                       error:NULL];
        if (data)
        {
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];

            if (array)
            {
                self.objects = array;
            }
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }

    return self;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self save];
}

- (void)updateContext:(NSMutableArray *)objects
{
    _objects = objects;
}

- (void)save
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_objects];
    [data writeToFile:self.URL.path options:NSDataWritingAtomic error:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
