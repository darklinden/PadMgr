//
//  O_logic.h
//  PadMgr
//
//  Created by user_admin on D/23/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface O_logic : NSObject

+ (NSArray *)get_app_list;
+ (NSString *)get_pad_path;
+ (NSArray *)get_account_list;
+ (NSString *)get_current_account_with_pad:(NSString *)pad_doc
                                  accounts:(NSArray *)accounts;
+ (BOOL)save_current_account_with_pad:(NSString *)pad_doc
                              account:(NSString *)account;
+ (BOOL)delete_current_account_with_pad:(NSString *)pad_doc;

+ (BOOL)load_current_account_with_pad:(NSString *)pad_doc
                              account:(NSString *)account;

@end
