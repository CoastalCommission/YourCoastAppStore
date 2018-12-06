//
//  UIApplication+MLX.m
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

#import "UIApplication+MLX.h"

@implementation UIApplication (MLX)

- (void)mlx_checkForUpdates:(NSURL *)url;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfURL:url];

        if (dictionary)
        {
            if ([[dictionary[@"items"] lastObject][@"metadata"][@"bundle-version"] isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] == NO)
            {
                dispatch_async(dispatch_get_main_queue(), ^{

                    UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    window.rootViewController = [[UIViewController alloc] init];
                    window.windowLevel = UIWindowLevelAlert + 1;

                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"An update is available.", nil) message:NSLocalizedString(@"Would you like to update now?", nil) preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:nil]];
                    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

                        NSString *string = [[NSString alloc] initWithFormat:@"itms-services://?action=download-manifest&amp;url=%@", [url absoluteString]];

                        NSURL *url = [[NSURL alloc] initWithString:string];
                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                    }]];

                    [window makeKeyAndVisible];
                    [window.rootViewController presentViewController:alertController animated:true completion:nil];
                });
            }
        }
    });
}

@end
