//
//  NSLayoutConstraint+MLX.m
//
//  Copyright (c) 2013 MetaLab.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NSLayoutConstraint+MLX.h"
#import "NSArray+MLX.h"

#ifdef MLX_FORCE_CATEGORY_LINK
    MLX_FORCE_CATEGORY_LINK(NSLayoutConstraint);
#endif

@implementation NSLayoutConstraint (MLX)

+ (NSArray<NSLayoutConstraint *> *)mlx_constraintsWithVisualFormats:(NSArray<NSString *> *)formats metrics:(NSDictionary *)metrics views:(NSDictionary *)views
{
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] mlx_initWithObject:@(0) count:[formats count]]
                                                             forKeys:formats];
    
    return [self mlx_constraintsWithVisualFormatsAndOptions:dictionary
                                                    metrics:metrics
                                                      views:views];
}

+ (NSArray<NSLayoutConstraint *> *)mlx_constraintsWithVisualFormatsAndOptions:(NSDictionary *)formatsAndOptions metrics:(NSDictionary *)metrics views:(NSDictionary *)views
{
    __block NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[formatsAndOptions count]];
    
    [formatsAndOptions enumerateKeysAndObjectsUsingBlock:^(NSString *format, NSNumber *options, BOOL *stop) {
        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                       options:[options unsignedIntegerValue]
                                                                       metrics:metrics
                                                                         views:views];
        [array addObjectsFromArray:constraints];
    }];
    
    return [[NSArray alloc] initWithArray:array];
}

@end
