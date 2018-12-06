//
//  CCCDataClient.m
//  Coastal
//
//  Created by Oliver White on 1/28/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCDataClient.h"
#import "CCCURLCache.h"
#import "CCCAccessPoint.h"

static NSString * const kCoastalDeviceIdentifier = @"Coastal-Device-Identifier";
static NSString * const kCoastalGovAPIScheme = @"http";
static NSString * const kCoastalGovAPIHost = @"api.coastal.ca.gov";

#define kCoastalAPIScheme [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CCC_API_SCHEME"]
#define kCoastalAPIHost [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CCC_API_HOST"]
#define DEVICE_IDENTIFIER [[[UIDevice currentDevice] identifierForVendor] UUIDString]

@implementation CCCDataClient

static NSString * const CCCUpdatedAtKey = @"CCCUpdatedAt";
static NSString * const CCCCheckedAtKey = @"CCCCheckedAt";

+ (void)getAccessPoints:(void (^)(NSArray *, BOOL))completion
{
    NSURL *documentsURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                   inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"access_points.json"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:[documentsURL path]] == NO)
    {
        NSURL *bundleURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:[documentsURL lastPathComponent]];

        if ([[NSFileManager defaultManager] copyItemAtURL:bundleURL
                                                    toURL:documentsURL
                                                    error:NULL])
        {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:1411157799.0];
            [[NSUserDefaults standardUserDefaults] setObject:date
                                                      forKey:CCCUpdatedAtKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            documentsURL = bundleURL;
        }
    }

    { // Local cache
        NSArray *items = nil;

        NSData *data = [[NSData alloc] initWithContentsOfURL:documentsURL];
        if (data)
        {
            items = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingMutableContainers
                                                      error:NULL];
        }

        if (completion != nil) {
            completion(items, YES);
        }
    }

    NSDate *checkedAt = [[NSUserDefaults standardUserDefaults] objectForKey:CCCCheckedAtKey];
    if (checkedAt && ([checkedAt timeIntervalSinceNow] > -3600.0))
    {
        return;
    }

    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = kCoastalGovAPIScheme;
    components.host = kCoastalGovAPIHost;
    components.path = @"/access/v1/locations";

    NSURL *url = components.URL;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;

    NSDate *updatedAt = [[NSUserDefaults standardUserDefaults] objectForKey:CCCUpdatedAtKey];
    if (updatedAt)
    {
        [request setValue:^NSString *{

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
            [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];

            return [formatter stringFromDate:updatedAt];
        }()
       forHTTPHeaderField:@"If-Modified-Since"];
    }

   NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (data && [(NSHTTPURLResponse *)response statusCode] == 200)
        {
            NSArray *items = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:NULL];

            if (completion != nil) {
                completion(items, NO);
            }

            if (items.count > 0 && [data writeToURL:documentsURL atomically:YES])
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:CCCCheckedAtKey];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:CCCUpdatedAtKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }];
    [dataTask resume];
}

+ (void)getAccessPoint:(NSNumber *)identifier
            completion:(void (^)(NSDictionary *))completion
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = kCoastalGovAPIScheme;
    components.host = kCoastalGovAPIHost;
    components.path = [@"/access/v1/locations/" stringByAppendingString:[identifier stringValue]];

    NSURL *url = components.URL;

    __block NSDictionary *object = [CCCURLCache sharedCache][url];
    if (object == nil)
    {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setValue:DEVICE_IDENTIFIER forHTTPHeaderField:kCoastalDeviceIdentifier];

        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

            if (data && [(NSHTTPURLResponse *)response statusCode] == 200)
            {
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:kNilOptions
                                                                             error:NULL];

                if ([dictionary isKindOfClass:[NSDictionary class]])
                {
                    [CCCURLCache sharedCache][url] = object = dictionary;
                }
            }

            if (completion != nil) {
                completion(object);
            }
        }];
        [dataTask resume];

        if (completion != nil) {
            completion(object);
        }
    }
}

@end
