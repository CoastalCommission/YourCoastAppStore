//
//  UIView+MLX.m
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

#import "UIView+MLX.h"
#import <objc/runtime.h>

NSDictionary *_MLXDictionaryOfPropertyBindings(NSString *commaSeparatedKeysString, id firstValue, ...)
{
    va_list arguments;
    va_start(arguments, firstValue);

    id value = firstValue;

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    NSArray *keys = [commaSeparatedKeysString componentsSeparatedByString:@","];

    for (NSString *key in keys)
    {
        NSArray *separatedKey = [key componentsSeparatedByString:@"."];

        if (value)
        {
            dictionary[[separatedKey lastObject]] = value;
        }

        value = va_arg(arguments, id);
    }

    va_end(arguments);

    return [dictionary copy];
}

NSDictionary *MLXDictionaryOfPropertyBindingsForObjectClimbingClassesFromClassToSuperclass(id object, Class currentClass, Class superClass)
{
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(currentClass, &propertyCount);
    NSMutableDictionary *bindings = [[NSMutableDictionary alloc] initWithCapacity:propertyCount];

    if ([currentClass superclass] != [superClass class])
    {
        NSDictionary *superBindings = MLXDictionaryOfPropertyBindingsForObjectClimbingClassesFromClassToSuperclass(object, [currentClass superclass], superClass);
        [bindings addEntriesFromDictionary:superBindings];
    }

    if (properties)
    {
        for (unsigned int index = 0; index < propertyCount; index++)
        {
            NSString *propertyType = @(property_copyAttributeValue(properties[index], "T"));

            if ([propertyType hasPrefix:@"@"])
            {
                NSString *propertyName = @(property_getName(properties[index]));

                bindings[propertyName] = [object valueForKey:propertyName] ?: [NSNull null];
            }
        }
        free(properties);
    }
    return bindings;
}

NSDictionary *MLXDictionaryOfPropertyBindingsForObject(id object, Class superClass)
{
    return MLXDictionaryOfPropertyBindingsForObjectClimbingClassesFromClassToSuperclass(object, [object class], superClass);
}

static NSString * const MLXUIViewNeedsAddConstraints = @"MLXUIViewNeedsAddConstraintsKey";

@interface UIView ()

@property (nonatomic, assign) BOOL mlx_needsAddConstraints;

@end

@implementation UIView (MLX)

- (void)setMlx_needsAddConstraints:(BOOL)mlx_needsAddConstraints
{
    objc_setAssociatedObject(self, &MLXUIViewNeedsAddConstraints, @(mlx_needsAddConstraints), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)mlx_needsAddConstraints
{
    NSNumber *number = objc_getAssociatedObject(self, &MLXUIViewNeedsAddConstraints);

    if (number == nil)
    {
        self.mlx_needsAddConstraints = YES;
        number = @YES;
    }

    return [number boolValue];
}

- (NSArray *)mlx_constraints
{
    return [[NSArray alloc] init];
}

- (void)mlx_addConstraintsIfNeeded
{
    if (self.mlx_needsAddConstraints == YES)
    {
        UIView *view = self;

        if ([view isKindOfClass:[UITableViewCell class]] == YES)
        {
            view = ((UITableViewCell *)view).contentView;
        }

        if ([view isKindOfClass:[UITableViewHeaderFooterView class]] == YES)
        {
            view = ((UITableViewHeaderFooterView *)view).contentView;
        }

        [view addConstraints:[self mlx_constraints]];
        self.mlx_needsAddConstraints = NO;
    }
}

- (void)mlx_removeAllSubviews
{
    UIView *subview = nil;
    while ((subview = [self.subviews lastObject]))
    {
        [subview removeFromSuperview];
    }
}

- (void)mlx_shake:(void (^)(BOOL finished))completion
{
    CGFloat horizontalDisplacement = 4.0;

    CGAffineTransform leftTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, horizontalDisplacement, 0);
    CGAffineTransform rightTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, -horizontalDisplacement, 0);

    self.transform = leftTransform;

    [UIView animateWithDuration:0.07 delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{

        [UIView setAnimationRepeatCount:2];
        self.transform = rightTransform;

    } completion:^(BOOL finished) {

        if (finished == YES)
        {
            self.transform = CGAffineTransformIdentity;
        }

        if (completion != nil)
        {
            completion(finished);
        }
    }];
}

@end
