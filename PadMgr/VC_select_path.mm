//
//  VC_select_path.m
//  PadMgr
//
//  Created by user_admin on D/25/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import "VC_select_path.h"
#import "O_logic.h"

#define PAD_MANUALLY_SET_PATH_KEY   @"PAD_MANUALLY_SET_PATH_KEY"

@interface VC_select_path () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UITableView      *table_app_list;
@property (nonatomic, assign) id<Delegate_select_path>  delegate;

@property (nonatomic, retain) NSArray                   *array_apps;
@property (nonatomic, retain) NSString                  *path_selected;

@end

@implementation VC_select_path

- (void)dealloc
{
    _delegate = nil;
    
    if (_table_app_list) {
        [_table_app_list removeFromSuperview];
        [_table_app_list release], _table_app_list = nil;
    }
    
    if (_array_apps) {
        [_array_apps release], _array_apps = nil;
    }
    
    if (_path_selected) {
        [_path_selected release], _path_selected = nil;
    }
    
    [super dealloc];
}

+ (void)show_selector_with_delegate:(id)delegate
{
    VC_select_path *vc_ = [[VC_select_path alloc] initWithNibName:nil bundle:nil];
    vc_.delegate = delegate;
    UINavigationController *nc_ = [[UINavigationController alloc] initWithRootViewController:vc_];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nc_.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    UIViewController *vc_root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc_root presentViewController:nc_ animated:YES completion:nil];
    [vc_ release];
    [nc_ release];
}

+ (NSString *)saved_path
{
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:PAD_MANUALLY_SET_PATH_KEY];
    if (path) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return path;
        }
    }
    return nil;
}

+ (void)save_path:(NSString *)path
{
    if (path) {
        [[NSUserDefaults standardUserDefaults] setObject:path forKey:PAD_MANUALLY_SET_PATH_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PAD_MANUALLY_SET_PATH_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect rect = self.view.bounds;
    rect.origin.y += 64;
    rect.size.height -= 64;
    
    _table_app_list = [[UITableView alloc] initWithFrame:rect];
    self.table_app_list.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_table_app_list];
    _table_app_list.delegate = self;
    _table_app_list.dataSource = self;
    
    UIBarButtonItem *item_done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.leftBarButtonItem = item_done;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(reload) withObject:nil afterDelay:0.01f];
}

- (void)reload
{
    self.array_apps = [O_logic get_app_list];
    [self.table_app_list reloadData];
}

- (void)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array_apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"AccCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row < self.array_apps.count) {
        NSDictionary *dict = self.array_apps[indexPath.row];
        cell.textLabel.text = [dict.allKeys firstObject];
    }
    else {
        cell.textLabel.text = @"error";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.path_selected = nil;
    if (indexPath.row < self.array_apps.count) {
        NSDictionary *dict = self.array_apps[indexPath.row];
        self.path_selected = [dict.allValues firstObject];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:[NSString stringWithFormat:@"手动设置PAD路径为\"%@\"", self.path_selected]
                                                   delegate:self
                                          cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
}

#pragma mark - alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex) {
        [[self class] save_path:self.path_selected];
        
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(select_path:)]) {
                [self.delegate select_path:self.path_selected];
            }
        }
    }
}

@end
