//
//  CCCAboutView.m
//  Coastal
//
//  Created by Cezar on 19/05/16.
//  Copyright © 2016 MetaLab. All rights reserved.
//

#import "CCCAboutView.h"
#import "UIView+MLX.h"
#import "NSLayoutConstraint+MLX.h"
#import "UIColor+CCCColorPallete.h"
#import "UIFont+CCCTypeFoundry.h"

@interface CCCAboutView ()

@property (nonatomic, strong) UIButton *feedbackButton;
@property (nonatomic, strong) UILabel *firstTitleLabel;
@property (nonatomic, strong) UILabel *secondTitleLabel;
@property (nonatomic, strong) UILabel *attributionTitleLabel;
@property (nonatomic, strong) UILabel *thirdTitleLabel;
@property (nonatomic, strong) UITextView *firstTextView;
@property (nonatomic, strong) UITextView *secondTextView;
@property (nonatomic, strong) UITextView *attributionTextView;
@property (nonatomic, strong) UITextView *thirdTextView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UILabel *footerLabel;

@property (nonatomic, strong) NSDictionary *textViewAttributes;

@end

@implementation CCCAboutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor whiteColor];

        [self.contentView addSubview:self.feedbackButton];
        [self.contentView addSubview:self.firstTitleLabel];
        [self.contentView addSubview:self.secondTitleLabel];
        [self.contentView addSubview:self.thirdTitleLabel];
        [self.contentView addSubview:self.firstTextView];
        [self.contentView addSubview:self.secondTextView];
        [self.contentView addSubview:self.thirdTextView];
        [self.contentView addSubview:self.separatorView];
        [self.contentView addSubview:self.footerLabel];
        [self.contentView addSubview:self.attributionTitleLabel];
        [self.contentView addSubview:self.attributionTextView];

        [self setNeedsUpdateConstraints];
    }

    return self;
}

- (void)updateConstraints{
    [self mlx_addConstraintsIfNeeded];

    [super updateConstraints];
}

- (NSArray *)mlx_constraints
{
    NSMutableArray *constraints = [[super mlx_constraints] mutableCopy];

    NSDictionary *formats = @{
                              @"V:|-32-[feedbackButton(48)]-32-[firstTitleLabel]-[firstTextView]-24-[secondTitleLabel]-[secondTextView]-24-[attributionTitleLabel]-[attributionTextView]-24-[thirdTitleLabel]-[thirdTextView]": @(NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight),
                              @"V:[thirdTextView]-32-[separatorView(1)]-32-[footerLabel]-54-|": @(NSLayoutFormatAlignAllCenterX),

                              @"H:|-32-[feedbackButton]-32-|": @0,
                              @"H:|-34-[separatorView]-34-|": @0,
                              @"H:|->=8-[footerLabel]->=8-|": @0,
                              };

    NSDictionary *metrics = @{
                              };

    NSDictionary *views = MLXDictionaryOfPropertyBindings(
                                                          self.feedbackButton,
                                                          self.firstTitleLabel,
                                                          self.secondTitleLabel,
                                                          self.thirdTitleLabel,
                                                          self.firstTextView,
                                                          self.secondTextView,
                                                          self.thirdTextView,
                                                          self.separatorView,
                                                          self.footerLabel,
                                                          self.attributionTextView,
                                                          self.attributionTitleLabel
                                                          );

    [constraints addObjectsFromArray:[NSLayoutConstraint mlx_constraintsWithVisualFormatsAndOptions:formats metrics:metrics views:views]];

    return constraints;
}

#pragma mark - Lazy accessors

- (UIButton *)feedbackButton
{
    if (_feedbackButton == nil)
    {
        _feedbackButton = [[UIButton alloc] init];
        _feedbackButton.translatesAutoresizingMaskIntoConstraints = NO;
        _feedbackButton.titleLabel.font = [UIFont ccc_textLabelFont];
        _feedbackButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _feedbackButton.layer.borderColor = [UIColor ccc_darkGrayTextColor].CGColor;
        _feedbackButton.layer.borderWidth = 1.0;
        _feedbackButton.layer.cornerRadius = 24.0f;
        [_feedbackButton setTitle:NSLocalizedString(@"Give Feedback", nil) forState:UIControlStateNormal];
        [_feedbackButton setTitleColor:[UIColor ccc_darkGrayTextColor] forState:UIControlStateNormal];
        [_feedbackButton setTitleColor:[[UIColor ccc_darkGrayTextColor] colorWithAlphaComponent: 0.5] forState:UIControlStateHighlighted];
    }

    return _feedbackButton;
}

- (UILabel *)firstTitleLabel
{
    if (_firstTitleLabel == nil)
    {
        _firstTitleLabel = [[UILabel alloc] init];
        _firstTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _firstTitleLabel.font = [UIFont ccc_detailedTextLabelFont];
        _firstTitleLabel.textColor = [UIColor ccc_lightTextColor];
        _firstTitleLabel.text = NSLocalizedString(@"Beach Access", nil);
        _firstTitleLabel.textAlignment = NSTextAlignmentLeft;
    }

    return _firstTitleLabel;
}

- (UILabel *)secondTitleLabel
{
    if (_secondTitleLabel == nil)
    {
        _secondTitleLabel = [[UILabel alloc] init];
        _secondTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _secondTitleLabel.font = [UIFont ccc_detailedTextLabelFont];
        _secondTitleLabel.textColor = [UIColor ccc_lightTextColor];
        _secondTitleLabel.text = NSLocalizedString(@"Information Notice", nil);
        _secondTitleLabel.textAlignment = NSTextAlignmentLeft;
    }

    return _secondTitleLabel;
}

- (UILabel *)attributionTitleLabel
{
    if (_attributionTitleLabel == nil)
    {
        _attributionTitleLabel = [[UILabel alloc] init];
        _attributionTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _attributionTitleLabel.font = [UIFont ccc_detailedTextLabelFont];
        _attributionTitleLabel.textColor = [UIColor ccc_lightTextColor];
        _attributionTitleLabel.text = NSLocalizedString(@"Attributions", nil);
        _attributionTitleLabel.textAlignment = NSTextAlignmentLeft;
    }

    return _attributionTitleLabel;
}

- (UILabel *)thirdTitleLabel
{
    if (_thirdTitleLabel == nil)
    {
        _thirdTitleLabel = [[UILabel alloc] init];
        _thirdTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _thirdTitleLabel.font = [UIFont ccc_detailedTextLabelFont];
        _thirdTitleLabel.textColor = [UIColor ccc_lightTextColor];
        _thirdTitleLabel.text = NSLocalizedString(@"Reporting Errors", nil);
        _thirdTitleLabel.textAlignment = NSTextAlignmentLeft;
    }

    return _thirdTitleLabel;
}

- (UITextView *)firstTextView
{
    if (_firstTextView == nil)
    {
        _firstTextView = [[UITextView alloc] init];
        _firstTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _firstTextView.editable = NO;
        _firstTextView.scrollEnabled = NO;
        _firstTextView.textContainer.lineFragmentPadding = 0;

        NSTextAttachment *attachment = [self textAttachmentWithImage:[UIImage imageNamed:@"coastal_access_logo"] font:[UIFont ccc_textLabelFont]];

        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"To find coastal accessways while on the road, look for the  ", nil)
                                                                                           attributes:[self textViewAttributes]];
        [attributedText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"  Coastal Access Logo symbol (the Coastal Commission's coastal access logo) that marks many (but not all) coastal access points. The California Constitution guarantees the public's right of access to tidelands, that is the area seaward of the mean high tide line. When visiting the coast, please observe any posted rules and please do not trespass on adjacent private lands. Always be alert for sleeper waves and other hazards; stay safe and enjoy the coast.", nil)
                                                                               attributes:[self textViewAttributes]]];

        _firstTextView.attributedText = attributedText;
    }

    return _firstTextView;
}

- (UITextView *)secondTextView
{
    if (_secondTextView == nil)
    {
        _secondTextView = [[UITextView alloc] init];
        _secondTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _secondTextView.editable = NO;
        _secondTextView.scrollEnabled = NO;
        _secondTextView.textContainer.lineFragmentPadding = 0;
        _secondTextView.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Location and attribute data are collected primarily from entries in the statewide California Coastal Access Guide: Seventh Edition (2014), and the 4-book set of regional Experience the California Coast guides (2005, 2007, 2009, 2012), all published by the University of California Press.", nil) attributes:[self textViewAttributes]];
    }

    return _secondTextView;
}

- (UITextView *)attributionTextView
{
    if (_attributionTextView == nil)
    {
        _attributionTextView = [[UITextView alloc] init];
        _attributionTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _attributionTextView.editable = NO;
        _attributionTextView.scrollEnabled = NO;
        _attributionTextView.textContainer.lineFragmentPadding = 0;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"\"Pram\" icon by Creative Stall is licensed under CC BY 3.0\n\"Binoculars\" icon by National Park Service Collection under CC BY 3.0" attributes:[self textViewAttributes]];
        [attributedString addAttribute:NSLinkAttributeName value:@"https://thenounproject.com/search/?q=stroller&i=132521" range:NSMakeRange(1,4)];
        [attributedString addAttribute:NSLinkAttributeName value:@"https://thenounproject.com/creativestall/" range:NSMakeRange(15,14)];
        [attributedString addAttribute:NSLinkAttributeName value:@"https://creativecommons.org/licenses/by/3.0/us/legalcode" range:NSMakeRange(47,10)];
        [attributedString addAttribute:NSLinkAttributeName value:@"https://thenounproject.com/search/?q=binoculars&i=112" range:NSMakeRange(59,10)];
        [attributedString addAttribute:NSLinkAttributeName value:@"https://thenounproject.com/edward/collection/national-park-service/" range:NSMakeRange(79,32)];
        [attributedString addAttribute:NSLinkAttributeName value:@"https://creativecommons.org/licenses/by/3.0/us/legalcode" range:NSMakeRange(118,9)];
        _attributionTextView.attributedText = attributedString;

    }

    return _attributionTextView;
}

- (UITextView *)thirdTextView
{
    if (_thirdTextView == nil)
    {
        _thirdTextView = [[UITextView alloc] init];
        _thirdTextView.translatesAutoresizingMaskIntoConstraints = NO;
        _thirdTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        _thirdTextView.editable = NO;
        _thirdTextView.scrollEnabled = NO;
        _thirdTextView.textContainer.lineFragmentPadding = 0;
        NSString *text = @"YourCoast has been constructed and is maintained by the California Coastal Commission. The data is a publicly available open data set of all California Coastal Access locations and their respective attributes. California Coastal Commission staff have attempted to insure the accuracy of this information. The State of California and the California Coastal Commission, however, make no representations or warranties regarding the accuracy of this dataset. If you believe there is an error or omission, notify the California Coastal Commission at PublicAccess@coastal.ca.gov or in writing to: Public Access Program, California Coastal Commission, 45 Fremont St, Suite 2000, San Francisco, CA 94105-2219.\n\nThanks!";
        _thirdTextView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self textViewAttributes]];
    }

    return _thirdTextView;
}

- (UIView *)separatorView
{
    if (_separatorView == nil)
    {
        _separatorView = [[UIView alloc] init];
        _separatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _separatorView.backgroundColor = [UIColor ccc_separatorColor];
    }

    return _separatorView;
}

- (UILabel *)footerLabel
{
    if (_footerLabel == nil)
    {
        _footerLabel = [[UILabel alloc] init];
        _footerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _footerLabel.numberOfLines = 2;
        _footerLabel.textAlignment = NSTextAlignmentCenter;

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 4.0;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attributes = @{
                                     NSForegroundColorAttributeName: [UIColor ccc_darkGrayTextColor],
                                     NSFontAttributeName: [UIFont ccc_textLabelFont],
                                     NSParagraphStyleAttributeName: paragraphStyle,
                                     };

        NSTextAttachment *attachment = [self textAttachmentWithImage:[UIImage imageNamed:@"heart_icon"] font:[UIFont ccc_textLabelFont]];

        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Made with ", nil) attributes:attributes];
        [attributedText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"\nby the California Coastal Commission", nil) attributes:attributes]];

        _footerLabel.attributedText = attributedText;
    }

    return _footerLabel;
}

- (NSDictionary *)textViewAttributes
{
    if (_textViewAttributes == nil)
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 4.0;
        _textViewAttributes = @{
                                     NSForegroundColorAttributeName: [UIColor ccc_darkGrayTextColor],
                                     NSFontAttributeName: [UIFont ccc_textLabelFont],
                                     NSParagraphStyleAttributeName: paragraphStyle,
                                     };
    }

    return _textViewAttributes;
}

#pragma mark - Helpers

- (NSTextAttachment *)textAttachmentWithImage:(UIImage *)image font:(UIFont *)font
{
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;

    //Center inline image vertically within text
    attachment.bounds = CGRectIntegral(CGRectMake(0, font.descender + font.capHeight - attachment.image.size.height / 2, attachment.image.size.width, attachment.image.size.height));

    return attachment;
}

@end
