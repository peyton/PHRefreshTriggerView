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

//@property (nonatomic, assign) UIEdgeInsets insets;

- (void)positionInScrollView:(UIScrollView *)scrollView;
- (void)transitionToRefreshState:(PHRefreshState)state;

@end

@interface PHRefreshTriggerView : UIView <PHRefreshTriggerView> {
    UILabel                 *_titleLabel;
    UIImageView             *_arrowView;
    UIActivityIndicatorView *_activityView;
    
    CFTimeInterval _arrowSpinAnimationDuration;
    CFTimeInterval _contentInsetAnimationDuration;
    
    BOOL _loading;
    BOOL _triggered;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, assign) CFTimeInterval arrowSpinAnimationDuration;
@property (nonatomic, assign) CFTimeInterval contentInsetAnimationDuration;

@property (nonatomic, assign, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, assign, readonly, getter = isTriggered) BOOL triggered;

@end
