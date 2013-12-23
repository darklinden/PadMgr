//
//  V_loading.m
//  PadMgr
//
//  Created by user_admin on D/23/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import "V_loading.h"

@implementation V_loading

static __strong UIView *view_static_loading = nil;

+ (void)add_loading
{
    if (view_static_loading) {
        [view_static_loading removeFromSuperview];
        view_static_loading = nil;
    }
    
    view_static_loading = [[UIView alloc] init];
    view_static_loading.translatesAutoresizingMaskIntoConstraints = NO;
    view_static_loading.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] init];
    act.translatesAutoresizingMaskIntoConstraints = NO;
    act.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [view_static_loading addSubview:act];
    [act startAnimating];
    
    //width
    [view_static_loading addConstraint:
     [NSLayoutConstraint constraintWithItem:act
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:0.f
                                   constant:act.frame.size.width]];
    
    //height
    [view_static_loading addConstraint:
     [NSLayoutConstraint constraintWithItem:act
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:0.f
                                   constant:act.frame.size.height]];
    
    //center x
    [view_static_loading addConstraint:
     [NSLayoutConstraint constraintWithItem:act
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:view_static_loading
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.f
                                   constant:0.f]];
    
    //center y
    [view_static_loading addConstraint:
     [NSLayoutConstraint constraintWithItem:act
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:view_static_loading
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1.f
                                   constant:0.f]];
    
    UIView *view_super = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    
    [view_super addSubview:view_static_loading];
    
    NSDictionary *dict_c = NSDictionaryOfVariableBindings(view_static_loading);
    
    [view_super addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"|[view_static_loading]|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:dict_c]];
    [view_super addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view_static_loading]|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:dict_c]];
}

+ (void)remove_loadng
{
    UIView *view_super = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    NSMutableArray *array_tmp = [NSMutableArray array];
    for (NSLayoutConstraint *c in view_super.constraints) {
        if ([c.firstItem isKindOfClass:[V_loading class]]
            || [c.secondItem isKindOfClass:[V_loading class]]) {
            [array_tmp addObject:c];
        }
    }
    [view_super removeConstraints:array_tmp];
    
    
    [view_static_loading removeFromSuperview];
    view_static_loading = nil;
}

@end
