//
//  PHRefreshTriggerView.h
//  PHRefreshTriggerView
//
//  Created by Pier-Olivier Thibault on 11-12-19.
//  Copyright (c) 2011 25th Avenue. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PHRefreshIdle = 0,
    PHRefreshTriggered,
    PHRefreshLoading
} PHRefreshState;

@protocol PHRefreshTriggerView;

@interface PHRefreshGestureRecognizer : UIGestureRecognizer {
    PHRefreshState _refreshState;
    UIView<PHRefreshTriggerView> *_triggerView;
    
    struct {
        BOOL isBoundToScrollView:1;
    } _triggerFlags;
}

@property (nonatomic, assign) PHRefreshState refreshState;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, strong) UIView<PHRefreshTriggerView> *triggerView;

@end

@interface UIScrollView (PHRefreshGestureRecognizer)

- (PHRefreshGestureRecognizer *)refreshGestureRecognizer;

@end