//
//  O_logic.m
//  PadMgr
//
//  Created by user_admin on D/23/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import "O_logic.h"

@implementation O_logic

+ (NSArray *)get_app_list
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //app home
    path = [path stringByDeletingLastPathComponent];
    
    //app list
    path = [path stringByDeletingLastPathComponent];
    
    NSError *err = nil;
    NSArray *array_apps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&err];
    
    NSMutableArray *array_app_list = [NSMutableArray array];
    for (NSString *name_app in array_apps) {
        
        NSString *path_app = [path stringByAppendingPathComponent:name_app];
        
        NSArray *array_tmp = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path_app error:nil];
        
        NSString *path_app_content = nil;
        for (NSString *name_tmp in array_tmp) {
            if ([[[name_tmp lowercaseString] pathExtension] isEqualToString:@"app"]) {
                path_app_content = [path_app stringByAppendingPathComponent:name_tmp];
                break;
            }
        }
        
        [array_app_list addObject:path_app_content];
    }
    
    return array_app_list;
}

+ (NSString *)get_pad_path
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //app home
    path = [path stringByDeletingLastPathComponent];
    
    //app list
    path = [path stringByDeletingLastPathComponent];
    
    NSError *err = nil;
    NSArray *array_apps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&err];
    
    NSString *path_pad_doc = nil;
    
    for (NSString *name_app in array_apps) {
        
        NSString *path_app = [path stringByAppendingPathComponent:name_app];
        
        NSArray *array_tmp = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path_app error:nil];
        
        NSString *path_app_content = nil;
        for (NSString *name_tmp in array_tmp) {
            if ([[[name_tmp lowercaseString] pathExtension] isEqualToString:@"app"]) {
                path_app_content = [path_app stringByAppendingPathComponent:name_tmp];
                break;
            }
        }
        
        if (![[[path_app_content lowercaseString] lastPathComponent] isEqualToString:@"pad.app"]) {
            continue;
        }
        
        NSString *path_info_plist = nil;
        NSArray *array_app_content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path_app_content error:nil];
        for (NSString *name_tmp in array_app_content) {
            if ([[[name_tmp lowercaseString] pathExtension] isEqualToString:@"plist"]) {
                if ([[name_tmp lowercaseString] rangeOfString:@"info"].location != NSNotFound) {
                    path_info_plist = [path_app_content stringByAppendingPathComponent:name_tmp];
                    break;
                }
            }
        }
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path_info_plist];
        
        if ([[dict objectForKey:@"CFBundleIdentifier"] isEqualToString:@"jp.gungho.pad"]) {
            path_pad_doc = [[path_app_content stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Documents"];
            break;
        }
    }
    
    return path_pad_doc;
}

+ (NSArray *)get_account_list
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSArray *array_acc = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    NSMutableArray *array_ret = [NSMutableArray array];
    
    for (NSString *string_name in array_acc) {
        NSString *path_tmp = [path stringByAppendingPathComponent:string_name];
        NSArray *array_tmp = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path_tmp error:nil];
        BOOL valid = NO;
        
        for (NSString *name_tmp in array_tmp) {
            if ([[name_tmp lowercaseString] isEqualToString:@"data048.bin"]) {
                valid = YES;
                break;
            }
        }
        
        if (valid) {
            [array_ret addObject:string_name];
        }
        else {
            [[NSFileManager defaultManager] removeItemAtPath:path_tmp error:nil];
        }
    }
    
    return [NSArray arrayWithArray:array_ret];
}

+ (NSString *)get_current_account_with_pad:(NSString *)pad_doc
                                  accounts:(NSArray *)accounts
{
    NSString *path_account = nil;
    NSData *data_remote = [NSData dataWithContentsOfFile:[pad_doc stringByAppendingPathComponent:@"data048.bin"]];
    
    NSString *path_doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    for (NSString *name_account in accounts) {
        NSString *path_acc = [path_doc stringByAppendingPathComponent:name_account];
        NSString *path_048 = [path_acc stringByAppendingPathComponent:@"data048.bin"];
        NSData *data_local = [NSData dataWithContentsOfFile:path_048];
        
        if ([data_local isEqual:data_remote]) {
            path_account = path_acc;
            break;
        }
    }
    
    return path_account;
}

+ (BOOL)save_current_account_with_pad:(NSString *)pad_doc
                              account:(NSString *)account
{
    BOOL ret = YES;
    NSString *local_048 = nil;
    //clean local
    NSArray *array_acc_content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:account error:nil];
    for (NSString *name_tmp in array_acc_content) {
        if (![[name_tmp lowercaseString] isEqualToString:@"data048.bin"]) {
            NSString *path_tmp = [account stringByAppendingPathComponent:name_tmp];
            ret = [[NSFileManager defaultManager] removeItemAtPath:path_tmp error:nil];
        }
        else {
            local_048 = [account stringByAppendingPathComponent:name_tmp];
        }
    }
    
    if (!ret) {
        return ret;
    }
    
    //copy remote
    NSArray *array_pad_content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pad_doc error:nil];
    for (NSString *name_tmp in array_pad_content) {
        NSString *path_tmp = [pad_doc stringByAppendingPathComponent:name_tmp];
        if ([[name_tmp lowercaseString] isEqualToString:@"mon2"]) {
            continue;
        }
        
        if ([[name_tmp lowercaseString] isEqualToString:@"data048.bin"]) {
            if (!local_048) {
                ret = [[NSFileManager defaultManager] copyItemAtPath:path_tmp
                                                              toPath:[account stringByAppendingPathComponent:name_tmp]
                                                               error:nil];
                if (!ret) {
                    break;
                }
            }
            
            continue;
        }
        
        ret = [[NSFileManager defaultManager] copyItemAtPath:path_tmp
                                                      toPath:[account stringByAppendingPathComponent:name_tmp]
                                                       error:nil];
        
        if (!ret) {
            break;
        }
    }
    
    return ret;
}

+ (BOOL)delete_current_account_with_pad:(NSString *)pad_doc
{
    BOOL ret = YES;
    NSArray *array_pad_content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pad_doc error:nil];
    for (NSString *name_tmp in array_pad_content) {
        NSString *path_tmp = [pad_doc stringByAppendingPathComponent:name_tmp];
        if ([[name_tmp lowercaseString] isEqualToString:@"mon2"]) {
            continue;
        }
        
        ret = [[NSFileManager defaultManager] removeItemAtPath:path_tmp error:nil];
        
        if (!ret) {
            break;
        }
    }
    
    return ret;
}

+ (BOOL)load_current_account_with_pad:(NSString *)pad_doc
                              account:(NSString *)account
{
    BOOL ret = [self delete_current_account_with_pad:pad_doc];
    if (!ret) {
        return ret;
    }
    
    NSArray *array_acc_content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:account error:nil];
    for (NSString *name_tmp in array_acc_content) {
        NSString *path_tmp = [account stringByAppendingPathComponent:name_tmp];
        NSString *path_remote = [pad_doc stringByAppendingPathComponent:name_tmp];
        ret = [[NSFileManager defaultManager] copyItemAtPath:path_tmp
                                                      toPath:path_remote
                                                       error:nil];
        
        if (!ret) {
            break;
        }
    }
    
    return ret;
}

@end
