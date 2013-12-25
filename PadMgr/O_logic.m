//
//  O_logic.m
//  PadMgr
//
//  Created by user_admin on D/23/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import "O_logic.h"
#include <stdio.h>
#include <dirent.h>
//#include "dos.h"
//#include "conio.h"

@implementation O_logic

+ (NSArray *)contentsOfDirectoryAtPath:(NSString *)directory
{
    if (!directory) {
        return nil;
    }
    
    DIR *directory_pointer;
    struct dirent *entry;
    
    directory_pointer = opendir(directory.UTF8String);
    NSMutableArray *array = [NSMutableArray array];
    if (NULL == directory_pointer) {
        return nil;
    }
    else {
        do {
            entry = readdir(directory_pointer);
            if (entry) {
                NSString *name = [NSString stringWithUTF8String:entry->d_name];
                if ([name isEqualToString:@"."]
                    || [name isEqualToString:@".."]) {
                    continue;
                }
//                NSLog(@"%s", entry->d_name);
                [array addObject:name];
            }
            
        } while (entry);
        
        closedir(directory_pointer);
    }
    
    return array;
}

+ (BOOL)removeItemAtPath:(NSString *)path
{
    if (!path) {
        return NO;
    }
    NSString *cmd = [NSString stringWithFormat:@"rm -rf \"%@\"", path];
    if (0 == system(cmd.UTF8String)) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)copyItemAtPath:(NSString *)src
                toPath:(NSString *)des
{
    if (!src || !des) {
        return NO;
    }
    NSString *cmd = [NSString stringWithFormat:@"cp \"%@\" \"%@\"", src, des];
    if (0 == system(cmd.UTF8String)) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)createDirectoryAtPath:(NSString *)path
{
    if (!path) {
        return NO;
    }
    NSString *cmd = [NSString stringWithFormat:@"mkdir \"%@\"", path];
    if (0 == system(cmd.UTF8String)) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)fileExistsAtPath:(NSString *)path
{
    //check if dir
    DIR *directory_pointer;
    directory_pointer = opendir(path.UTF8String);
    if (directory_pointer) {
        closedir(directory_pointer);
        return YES;
    }
    
    //check if file
    FILE* fp = fopen(path.UTF8String, "r");
    if (fp) {
        fclose(fp);
        return YES;
    }
    
    return NO;
}

+ (NSArray *)get_app_list
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    //app home
    path = [path stringByDeletingLastPathComponent];
    
    //app list
    path = [path stringByDeletingLastPathComponent];
    
    NSArray *array_apps = [self contentsOfDirectoryAtPath:path];
    
    NSMutableArray *array_app_list = [NSMutableArray array];
    for (NSString *name_app in array_apps) {
        
        NSString *path_app = [path stringByAppendingPathComponent:name_app];
        
        NSArray *array_tmp = [self contentsOfDirectoryAtPath:path_app];
        
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
    
    NSArray *array_apps = [self contentsOfDirectoryAtPath:path];
    
    NSString *path_pad_doc = nil;
    
    for (NSString *name_app in array_apps) {
        
        NSString *path_app = [path stringByAppendingPathComponent:name_app];
        
        NSArray *array_tmp = [self contentsOfDirectoryAtPath:path_app];
        
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
        NSArray *array_app_content = [self contentsOfDirectoryAtPath:path_app_content];
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
    
    NSArray *array_acc = [self contentsOfDirectoryAtPath:path];
    
    NSMutableArray *array_ret = [NSMutableArray array];
    
    for (NSString *string_name in array_acc) {
        NSString *path_tmp = [path stringByAppendingPathComponent:string_name];
        NSArray *array_tmp = [self contentsOfDirectoryAtPath:path_tmp];
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
            [self removeItemAtPath:path_tmp];
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
    NSArray *array_acc_content = [self contentsOfDirectoryAtPath:account];
    for (NSString *name_tmp in array_acc_content) {
        if (![[name_tmp lowercaseString] isEqualToString:@"data048.bin"]) {
            NSString *path_tmp = [account stringByAppendingPathComponent:name_tmp];
            ret = [self removeItemAtPath:path_tmp];
        }
        else {
            local_048 = [account stringByAppendingPathComponent:name_tmp];
        }
    }
    
    if (!ret) {
        return ret;
    }
    
    //copy remote
    NSArray *array_pad_content = [self contentsOfDirectoryAtPath:pad_doc];
    for (NSString *name_tmp in array_pad_content) {
        NSString *path_tmp = [pad_doc stringByAppendingPathComponent:name_tmp];
        if ([[name_tmp lowercaseString] isEqualToString:@"mon2"]) {
            continue;
        }
        
        if ([[name_tmp lowercaseString] isEqualToString:@"data048.bin"]) {
            if (!local_048) {
                ret = [self copyItemAtPath:path_tmp
                                    toPath:[account stringByAppendingPathComponent:name_tmp]];
                if (!ret) {
                    break;
                }
            }
            
            continue;
        }
        
        ret = [self copyItemAtPath:path_tmp
                            toPath:[account stringByAppendingPathComponent:name_tmp]];
        
        if (!ret) {
            break;
        }
    }
    
    return ret;
}

+ (BOOL)delete_current_account_with_pad:(NSString *)pad_doc
{
    BOOL ret = YES;
    NSArray *array_pad_content = [self contentsOfDirectoryAtPath:pad_doc];
    for (NSString *name_tmp in array_pad_content) {
        NSString *path_tmp = [pad_doc stringByAppendingPathComponent:name_tmp];
        if ([[name_tmp lowercaseString] isEqualToString:@"mon2"]) {
            continue;
        }
        
        ret = [self removeItemAtPath:path_tmp];
        
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
    
    NSArray *array_acc_content = [self contentsOfDirectoryAtPath:account];
    for (NSString *name_tmp in array_acc_content) {
        NSString *path_tmp = [account stringByAppendingPathComponent:name_tmp];
        NSString *path_remote = [pad_doc stringByAppendingPathComponent:name_tmp];
        ret = [self copyItemAtPath:path_tmp
                            toPath:path_remote];
        
        if (!ret) {
            break;
        }
    }
    
    return ret;
}

@end
