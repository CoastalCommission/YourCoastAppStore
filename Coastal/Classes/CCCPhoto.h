//
//  CCCPhoto.h
//  Coastal
//
//  Created by Aaron Williams on 2016-09-15.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NYTPhoto.h"

@interface CCCPhoto : NSObject
<
NYTPhoto
>

@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSURL *url;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end
