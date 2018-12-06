//
//  CCCPinAnnotationView.m
//  Coastal
//
//  Created by Oliver White on 2/18/2014.
//  Copyright (c) 2014 MetaLab. All rights reserved.
//

#import "CCCPinAnnotationView.h"
#import "CCCPinAnnotation.h"
#import "CCCCalloutView.h"

@interface CCCPinAnnotationView ()

@property (nonatomic, strong) CCCCalloutView *calloutView;
@property (nonatomic, assign) BOOL calloutTapped;

@end

@implementation CCCPinAnnotationView

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if(!isInside)
    {
        for (UIView *view in self.subviews)
        {
            isInside = CGRectContainsPoint(view.frame, point);
            if(isInside)
                break;
        }
    }
    return isInside;
}

#pragma mark - MKPinAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithAnnotation:annotation
                          reuseIdentifier:reuseIdentifier]))
    {
        self.calloutView = [[CCCCalloutView alloc] initWithFrame:CGRectZero];
        {
            [self.calloutView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCallout:)]];
        }
        [self addSubview:self.calloutView];
    }

    return self;
}

- (void)tapCallout:(UITapGestureRecognizer *)sender
{
    self.calloutTapped = YES;
    [self.delegate annotationView:self didTapCallout:(CCCCalloutView *)sender.view];
}

#pragma mark - Setters and Getters

- (void)setAnnotation:(CCCPinAnnotation <MKAnnotation> *)annotation
{
    [super setAnnotation:annotation];

    if (annotation)
    {
        self.image = [UIImage imageNamed:annotation.color];
        self.centerOffset = CGPointMake(0, - self.image.size.height / 2);
    }
}

- (void)setTitleText:(NSString *)titleText
{
    self.calloutView.locationName = titleText;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected == NO && self.calloutTapped)
    {
        self.calloutTapped = NO;
        return;
    }

    [super setSelected:selected animated:animated];

    if (selected)
    {
        [self.calloutView showAnimated:animated];
    }
    else
    {
        [self.calloutView hideAnimated:animated];
    }

    self.calloutView.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5f, -(self.calloutView.arrowHeight + CGRectGetHeight(self.frame) * 0.40f));
}

@end
