//
//  O_logic.h
//  PadMgr
//
//  Created by user_admin on D/23/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface O_logic : NSObject

#define DOC_SAVE_PATH @"/usr/padmgrdoc"

+ (NSArray *)contentsOfDirectoryAtPath:(NSString *)directory;

+ (BOOL)removeItemAtPath:(NSString *)path;

+ (BOOL)copyItemAtPath:(NSString *)src
                toPath:(NSString *)des;

+ (BOOL)fileExistsAtPath:(NSString *)path;

+ (BOOL)createDirectoryAtPath:(NSString *)path;

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

+ (BOOL)exchange_056_with_pad:(NSString *)pad_doc;

@end
