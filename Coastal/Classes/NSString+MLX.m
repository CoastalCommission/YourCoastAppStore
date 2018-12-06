//
//  NSString+MLX.m
//  Coastal
//
//  Created by Oliver White on 2/24/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+MLX.h"

@implementation NSString (MLX)

- (NSString *)mlx_MD5String
{
    const char *input = [self UTF8String];

    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), buffer);

    NSMutableString *output = [[NSMutableString alloc] initWithCapacity:(CC_MD5_DIGEST_LENGTH * 2)];
    for(NSUInteger index = 0; index < CC_MD5_DIGEST_LENGTH; index++)
    {
        [output appendFormat:@"%02x", buffer[index]];
    }

    return output;
}

@end
