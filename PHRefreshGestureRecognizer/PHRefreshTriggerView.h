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
    
    CFTimeInterval _arrowFadeAnimationDuration;
    CFTimeInterval _arrowSpinAnimationDuration;
    CFTimeInterval _contentInsetAnimationDuration;
    
    BOOL _loading;
    BOOL _triggered;
}

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSString *loadingText;
@property (nonatomic, strong) NSString *pullToRefreshText;
@property (nonatomic, strong) NSString *releaseText;

@property (nonatomic, assign) CFTimeInterval arrowFadeAnimationDuration;
@property (nonatomic, assign) CFTimeInterval arrowSpinAnimationDuration;
@property (nonatomic, assign) CFTimeInterval contentInsetAnimationDuration;

@property (nonatomic, assign, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, assign, readonly, getter = isTriggered) BOOL triggered;

@end
