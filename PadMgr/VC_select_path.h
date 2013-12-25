//
//  VC_select_path.h
//  PadMgr
//
//  Created by user_admin on D/25/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Delegate_select_path <NSObject>

- (void)select_path:(NSString *)path;

@end

@interface VC_select_path : UIViewController

+ (NSString *)saved_path;

+ (void)save_path:(NSString *)path;

+ (void)show_selector_with_delegate:(id)delegate;

@end
