//
//  PHRefreshTriggerView.m
//  PHRefreshTriggerView
//
//  Created by Pier-Olivier Thibault on 11-12-20.
//  Copyright (c) 2011 25th Avenue. All rights reserved.
//

#import "PHRefreshTriggerView.h"
#import <QuartzCore/QuartzCore.h>

@interface PHRefreshTriggerView ()

@property (nonatomic, assign, getter = isLoading) BOOL loading;
@property (nonatomic, assign, getter = isTriggered) BOOL triggered;

@end

@implementation PHRefreshTriggerView
@synthesize activityView = _activityView;
@synthesize arrowView = _arrowView;
@synthesize titleLabel = _titleLabel;

@synthesize loadingText = _loadingText;
@synthesize pullToRefreshText = _pullToRefreshText;
@synthesize releaseText = _releaseText;

@synthesize arrowFadeAnimationDuration = _arrowFadeAnimationDuration;
@synthesize arrowSpinAnimationDuration = _arrowSpinAnimationDuration;
@synthesize contentInsetAnimationDuration = _contentInsetAnimationDuration;

@synthesize loading = _loading;
@synthesize triggered = _triggered;

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    // Configure view
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Initialize activityView
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // Initialize arrowView
    self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blackArrow"]];
    
    // Initialize titleLabel
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    // Set defaults
    self.loadingText = NSLocalizedStringFromTable(@"Loading\u2026", @"PHRefreshTriggerView", @"Loading table view contents");
    self.pullToRefreshText = NSLocalizedStringFromTable(@"Pull to refresh\u2026", @"PHRefreshTriggerView", @"User may pull table view down to refresh");
    self.releaseText = NSLocalizedStringFromTable(@"Release\u2026", @"PHRefreshTriggerView", @"User pulled table view down past threshold");
    
    self.arrowFadeAnimationDuration = 0.18;
    self.arrowSpinAnimationDuration = 0.18;
    self.contentInsetAnimationDuration = 0.3;
    
    self.loading = NO;
    self.triggered = NO;
    
    return self;
}

- (void)dealloc {
    self.activityView = nil;
    self.arrowView  = nil;
    self.titleLabel = nil;
    
    self.loadingText = nil;
    self.pullToRefreshText = nil;
    self.releaseText = nil;
}

#pragma mark - Subview methods

- (void)didAddSubview:(UIView *)subview;
{
    [self setNeedsLayout];
}

- (void)layoutSubviews;
{
    // Position activityView
    self.activityView.layer.position = CGPointMake(30.0f, CGRectGetMidY(self.bounds));
    
    // Position arrowView
    [self.arrowView sizeToFit];
    self.arrowView.layer.position = CGPointMake(30.0f, CGRectGetMidY(self.bounds));
        
    // Position titleLabel
    [self.titleLabel sizeToFit];
    CGRect titleLabelFrame = self.titleLabel.frame;
    titleLabelFrame.origin = CGPointMake(60.0f, (CGRectGetHeight(self.bounds) - CGRectGetHeight(titleLabelFrame)) / 2.0f);
    self.titleLabel.frame = titleLabelFrame;
}

- (CGSize)sizeThatFits:(CGSize)size;
{
    return CGSizeMake(size.width, 64.0f);
}

#pragma mark - Getters and setters

- (void)setActivityView:(UIActivityIndicatorView *)activityView;
{
    if (activityView == self.activityView)
        return;
    
    [self.activityView removeFromSuperview];
    _activityView = activityView;
    [self addSubview:self.activityView];
}

- (void)setArrowView:(UIImageView *)arrowView;
{
    if (arrowView == self.arrowView)
        return;
    
    [self.arrowView removeFromSuperview];
    _arrowView = arrowView;
    [self addSubview:self.arrowView];
}

- (void)setTitleLabel:(UILabel *)titleLabel;
{
    if (titleLabel == self.titleLabel)
        return;

    [self.titleLabel removeFromSuperview];
    _titleLabel = titleLabel;
    [self addSubview:self.titleLabel];
}

#pragma mark - PHRefreshTriggerView methods

- (void)positionInScrollView:(UIScrollView *)scrollView;
{
    // Size trigger view
    CGSize triggerViewSize = [self sizeThatFits:CGSizeMake(CGRectGetWidth(scrollView.bounds), HUGE_VALF)];
    CGPoint triggerViewOrigin = CGPointMake(0.0, -triggerViewSize.height);
    
    CGRect triggerViewFrame = CGRectZero;
    triggerViewFrame.size = triggerViewSize;
    triggerViewFrame.origin = triggerViewOrigin;
    self.frame = triggerViewFrame;
}

- (void)transitionToRefreshState:(PHRefreshState)state;
{
    switch (state) {
        case PHRefreshTriggered:
        {
            [UIView animateWithDuration:self.arrowSpinAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
            } completion:NULL];

            self.titleLabel.text = self.releaseText;
            self.triggered = YES;
            
            break;
        }
        case PHRefreshIdle:
        {
            void (^updateTitle)(void) = ^{
                self.titleLabel.text = self.pullToRefreshText;
            };
            if (self.isLoading)
            {
                [UIView animateWithDuration:self.contentInsetAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    UIScrollView *scrollView = (UIScrollView *)self.superview;
                    scrollView.contentInset = UIEdgeInsetsMake(0.0f, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
                } completion:^(BOOL finished) {
                    [self.activityView stopAnimating];
                    self.arrowView.transform = CGAffineTransformIdentity;
                    self.arrowView.alpha = 1.0f;
                    
                    updateTitle();
                }];
                
                self.loading = NO;
            } else if (self.isTriggered)
            {
                [UIView animateWithDuration:self.arrowSpinAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.arrowView.transform = CGAffineTransformMakeRotation(0.0f);
                } completion:NULL];   
                
                updateTitle();
                
                self.triggered = NO;
            } else {
                updateTitle();
            }
            
            break;
        }
        case PHRefreshLoading:
        {
            [UIView animateWithDuration:self.contentInsetAnimationDuration animations:^{
                UIScrollView *scrollView = (UIScrollView *)self.superview;
                scrollView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.bounds), scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
            }];
            
            [self.activityView startAnimating];
            [UIView animateWithDuration:self.arrowFadeAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.arrowView.alpha = 0.0f;
            } completion:NULL];
            
            self.titleLabel.text = self.loadingText;
            
            self.loading = YES;
            
            break;
        }
    }
    
    [self setNeedsLayout];
}

@end
