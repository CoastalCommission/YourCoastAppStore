//
//  UIView+MLX.h
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

#import <UIKit/UIKit.h>

/**
 *  Similar to NSDictionaryOfVariableBindings, but introspects an objects property list to build the dictionary.
 *  Includes properties from super classes, walking up to a given class.
 *
 *  @param object The object to instrospect the properties on, if being used in a subclass of UIView, this will usually be "self"
 *  @param superClass Which class to stop introspecting properties at. This is usually the UIKit base class, such as UIView, or UITableViewCell, that the view is based on.
 *
 *  @return an NSDictionary containing property keys and their corresponding values.
 */
extern NSDictionary *MLXDictionaryOfPropertyBindingsForObject(id object, Class superClass) DEPRECATED_MSG_ATTRIBUTE("Please use MLXDictionaryOfPropertyBindings instead");

/**
 *  Similar to NSDictionaryOfVariableBindings, but removes pre-pended dot notations
 *
 *  @param properties Comma-seperated list of view properties (eg: self.view1, self.view2)
 *
 *  @return an NSDictionary containing property keys and their corresponding values.
 */
#define MLXDictionaryOfPropertyBindings(...) _MLXDictionaryOfPropertyBindings(@"" # __VA_ARGS__, __VA_ARGS__, nil)
extern NSDictionary *_MLXDictionaryOfPropertyBindings(NSString *commaSeparatedKeysString, id firstValue, ...); // not for direct use

@interface UIView (MLX)

- (void)mlx_addConstraintsIfNeeded; // To be called in - (void)updateConstraints;
- (NSArray *)mlx_constraints;

- (void)mlx_removeAllSubviews;

/**
 Quickly moves the view back and forth horizontally.
 */
- (void)mlx_shake:(void (^)(BOOL finished))completion;

@end
