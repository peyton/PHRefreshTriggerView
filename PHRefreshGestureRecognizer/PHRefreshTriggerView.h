//
//  PHRefreshTriggerView.h
//  PHRefreshTriggerView
//
//  Created by Pier-Olivier Thibault on 11-12-20.
//  Copyright (c) 2011 25th Avenue. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PHRefreshGestureRecognizer.h"

@protocol PHRefreshTriggerView

- (void)positionInScrollView:(UIScrollView *)scrollView;
- (void)transitionToRefreshState:(PHRefreshState)state;

@end

@interface PHRefreshTriggerView : UIView <PHRefreshTriggerView> 
{
    UIActivityIndicatorView *_activityView;
    UIImageView *_arrowView;
    UILabel *_titleLabel;
    
    NSString *_loadingText;
    NSString *_pullToRefreshText;
    NSString *_releaseText;
    
    NSTimeInterval _arrowFadeAnimationDuration;
    NSTimeInterval _arrowSpinAnimationDuration;
    NSTimeInterval _contentInsetAnimationDuration;
    
    BOOL _loading;
    BOOL _triggered;
}

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSString *loadingText;
@property (nonatomic, strong) NSString *pullToRefreshText;
@property (nonatomic, strong) NSString *releaseText;

@property (nonatomic, assign) NSTimeInterval arrowFadeAnimationDuration;
@property (nonatomic, assign) NSTimeInterval arrowSpinAnimationDuration;
@property (nonatomic, assign) NSTimeInterval contentInsetAnimationDuration;

@property (nonatomic, assign, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, assign, readonly, getter = isTriggered) BOOL triggered;

@end
