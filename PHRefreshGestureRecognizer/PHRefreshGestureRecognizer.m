//
//  PHRefreshTriggerView.m
//  PHRefreshTriggerView
//
//  Created by Pier-Olivier Thibault on 11-12-19.
//  Copyright (c) 2011 25th Avenue. All rights reserved.
//

#import "PHRefreshGestureRecognizer.h"

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

#import "PHRefreshTriggerView.h"

static NSString * const PHRefreshViewKeyPath = @"view";

@implementation PHRefreshGestureRecognizer
@synthesize triggerView = _triggerView;
@synthesize refreshState = _refreshState;

- (id)initWithTarget:(id)target action:(SEL)action;
{    
    if (!(self = [super initWithTarget:target action:action]))
        return nil;
        
    [self addObserver:self forKeyPath:PHRefreshViewKeyPath options:NSKeyValueObservingOptionNew context:NULL];
        
    return self;
}

- (void)dealloc;
{
    [self removeObserver:self forKeyPath:PHRefreshViewKeyPath];
    self.triggerView = nil;
}

#pragma mark - Getters and setters

- (void)setRefreshState:(PHRefreshState)refreshState;
{
    if (refreshState == self.refreshState)
        return;
    
    [self willChangeValueForKey:@"refreshState"];
    _refreshState = refreshState;
    [self.triggerView transitionToRefreshState:refreshState];
    [self didChangeValueForKey:@"refreshState"];
}

- (UIScrollView *)scrollView;
{
    return (UIScrollView *)self.view;
}

- (UIView *)triggerView;
{
    if (_triggerView == nil)
        self.triggerView = [[PHRefreshTriggerView alloc] initWithFrame:CGRectZero];
    
    return _triggerView;
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    id newValue = [change valueForKey:NSKeyValueChangeNewKey];
    
    if ([keyPath isEqualToString:PHRefreshViewKeyPath])
        if ([newValue isKindOfClass:[UIScrollView class]])
        {
            _triggerFlags.isBoundToScrollView = YES;
            [newValue addSubview:self.triggerView];
            [self.triggerView positionInScrollView:newValue];
        } else
            _triggerFlags.isBoundToScrollView = NO;

}

#pragma mark - UIGestureRecognizer methods
- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer;
{
    return NO;
}
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer;
{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if (self.refreshState == PHRefreshLoading || !_triggerFlags.isBoundToScrollView)
    {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if (self.refreshState == PHRefreshLoading)
    {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if (_triggerFlags.isBoundToScrollView)
        if (self.scrollView.contentOffset.y < CGRectGetMinY(self.triggerView.frame))
            self.refreshState = PHRefreshTriggered;
        else if (self.state != UIGestureRecognizerStateRecognized)
            self.refreshState = PHRefreshIdle;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if (self.refreshState == PHRefreshLoading)
    {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    if (_triggerFlags.isBoundToScrollView)
        if (self.refreshState == PHRefreshTriggered)
        {
            self.refreshState = PHRefreshLoading;
            self.state = UIGestureRecognizerStateRecognized;
        } else {
            self.refreshState = PHRefreshIdle;
            self.state = UIGestureRecognizerStateFailed;
        }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
    self.state = UIGestureRecognizerStateFailed;
}

@end

#pragma mark - UIScrollView category

@implementation UIScrollView (PHRefreshGestureRecognizer)

- (PHRefreshGestureRecognizer *)refreshGestureRecognizer;
{
    for (PHRefreshGestureRecognizer *recognizer in self.gestureRecognizers)
        if ([recognizer isKindOfClass:[PHRefreshGestureRecognizer class]])
            return recognizer;
    return nil;
}

@end
