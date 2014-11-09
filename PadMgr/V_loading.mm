//
//  V_loading.m
//  PadMgr
//
//  Created by user_admin on D/23/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import "V_loading.h"

@implementation V_loading

static UIView *view_static_loading = nil;

+ (void)add_loading
{
    if (view_static_loading) {
        [view_static_loading removeFromSuperview];
        [view_static_loading release];
        view_static_loading = nil;
    }
    
    view_static_loading = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    view_static_loading.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    UIActivityIndicatorView *act = [[[UIActivityIndicatorView alloc] init] autorelease];
    act.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [view_static_loading addSubview:act];
    [act startAnimating];
    
    UIView *view_super = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    
    [view_super addSubview:view_static_loading];
    
    view_static_loading.frame = view_super.bounds;
    view_static_loading.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleBottomMargin;
    act.center = view_static_loading.center;
    act.autoresizingMask = UIViewAutoresizingNone;
}

+ (void)remove_loadng
{
    if (view_static_loading) {
        if (view_static_loading.superview) {
            [view_static_loading removeFromSuperview];
        }
        [view_static_loading release];
        view_static_loading = nil;
    }
}

@end
