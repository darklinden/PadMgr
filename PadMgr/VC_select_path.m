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
@property (nonatomic,   weak) IBOutlet UITableView      *table_app_list;
@property (nonatomic,   weak) id<Delegate_select_path>  delegate;

@property (nonatomic, strong) NSArray                   *array_apps;
@property (nonatomic, strong) NSString                  *path_selected;

@end

@implementation VC_select_path

+ (void)show_selector_with_delegate:(id)delegate
{
    VC_select_path *vc_ = [[VC_select_path alloc] initWithNibName:@"VC_select_path" bundle:nil];
    vc_.delegate = delegate;
    UINavigationController *nc_ = [[UINavigationController alloc] initWithRootViewController:vc_];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nc_.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    UIViewController *vc_root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc_root presentViewController:nc_ animated:YES completion:nil];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row < self.array_apps.count) {
        cell.textLabel.text = [self.array_apps[indexPath.row] lastPathComponent];
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
        self.path_selected = self.array_apps[indexPath.row];
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
