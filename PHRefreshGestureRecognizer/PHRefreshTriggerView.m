//
//  PHRefreshTriggerView.m
//  PHRefreshTriggerView
//
//  Created by Pier-Olivier Thibault on 11-12-20.
//  Copyright (c) 2011 25th Avenue. All rights reserved.
//

#import "PHRefreshTriggerView.h"
#import <QuartzCore/QuartzCore.h>

NSString * const PHSpinAnimationKey = @"PHSpinAnimationKey";
NSString * const PHResetAnimationKey = @"PHResetAnimationKey";

@interface PHRefreshTriggerView ()

@property (nonatomic, assign, getter = isLoading) BOOL loading;
@property (nonatomic, assign, getter = isTriggered) BOOL triggered;

- (CAAnimation *)_createRotationAnimationWithAngle:(CGFloat)angle;

@end

@implementation PHRefreshTriggerView
@synthesize titleLabel = _titleLabel;
@synthesize activityView = _activityView;
@synthesize arrowView = _arrowView;

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
    [self addSubview:self.activityView];
    
    // Initialize arrowView
    self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blackArrow"]];
    [self addSubview:self.arrowView];
    
    // Initialize titleLabel
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLabel];

    // Set up KVO
    [self.titleLabel addObserver:self forKeyPath:@"text" options:0 context:NULL];
    
    // Set defaults
    self.arrowSpinAnimationDuration = 0.18;
    self.contentInsetAnimationDuration = 0.3;
    [self transitionToRefreshState:PHRefreshIdle];
    
    return self;
}

- (void)dealloc {
    [self.titleLabel removeObserver:self forKeyPath:@"text"];
    self.arrowView  = nil;
    self.titleLabel = nil;
}

#pragma mark - Subview methods

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
            [self.arrowView.layer addAnimation:[self _createRotationAnimationWithAngle:M_PI] forKey:PHSpinAnimationKey];
            self.titleLabel.text = NSLocalizedStringFromTable(@"Release\u2026", @"PHRefreshTriggerView", @"User pulled table view down past threshold");                
            
            self.triggered = YES;
            
            break;
        case PHRefreshIdle:
            if (self.isLoading)
            {
                [UIView animateWithDuration:self.contentInsetAnimationDuration animations:^{
                    UIScrollView *scrollView = (UIScrollView *)self.superview;
                    scrollView.contentInset = UIEdgeInsetsMake(0.0f, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
                }];
                
                [self.activityView stopAnimating];
                self.arrowView.hidden = NO;
                [self.arrowView.layer removeAllAnimations];
                
                self.loading = NO;
            } else if (self.isTriggered)
            {
                [self.arrowView.layer addAnimation:[self _createRotationAnimationWithAngle:0.0f] forKey:PHResetAnimationKey];    
                
                self.triggered = NO;
            }
            
            self.titleLabel.text = NSLocalizedStringFromTable(@"Pull to refresh\u2026", @"PHRefreshTriggerView", @"User may pull table view down to refresh");
            break;
        case PHRefreshLoading:
            [UIView animateWithDuration:self.contentInsetAnimationDuration animations:^{
                UIScrollView *scrollView = (UIScrollView *)self.superview;
                scrollView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.bounds), scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
            }];
            
            [self.activityView startAnimating];
            self.arrowView.hidden = YES;
            self.titleLabel.text = NSLocalizedStringFromTable(@"Loading\u2026", @"PHRefreshTriggerView", @"Loading table view contents");
            
            self.loading = YES;
            
            break;
    }
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if (object == self.titleLabel && [keyPath isEqualToString:@"text"])
        [self setNeedsLayout];
}

#pragma mark - FOR PRIVATE EYES ONLY

- (CAAnimation *)_createRotationAnimationWithAngle:(CGFloat)angle;
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = self.arrowSpinAnimationDuration;
    animation.toValue = [NSNumber numberWithFloat:angle];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

@end
