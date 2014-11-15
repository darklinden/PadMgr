//
//  ViewController.m
//  PadMgr
//
//  Created by user_admin on D/23/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import "ViewController.h"
#import "V_loading.h"
#import "O_logic.h"
#import "VC_select_path.h"

#define Tag_alert_load_select_account       122301
#define Tag_alert_save_account_new_name     122302
#define Tag_alert_delete_current_account    122303
#define Tag_alert_manually_set_path         122304

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, Delegate_select_path>

@property (nonatomic,   retain) UITableView   *table_acc_list;

@property (nonatomic, retain) NSString      *path_pad_doc;

@property (nonatomic, retain) NSArray       *array_acc_list;
@property (nonatomic, retain) NSIndexPath   *index_last_select;

@end

@implementation ViewController

- (void)dealloc
{
    if (_table_acc_list) {
        [_table_acc_list removeFromSuperview];
        [_table_acc_list release], _table_acc_list = nil;
    }
    
    if (_path_pad_doc) {
        [_path_pad_doc release], _path_pad_doc = nil;
    }
    
    if (_array_acc_list) {
        [_array_acc_list release], _array_acc_list = nil;
    }
    
    if (_index_last_select) {
        [_index_last_select release], _index_last_select = nil;
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGRect rect = self.view.bounds;
    rect.origin.y += 64;
    rect.size.height -= 64;
    
    _table_acc_list = [[UITableView alloc] initWithFrame:rect];
    self.table_acc_list.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_table_acc_list];
    _table_acc_list.delegate = self;
    _table_acc_list.dataSource = self;
    
    UIBarButtonItem *item_reload = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStyleBordered target:self action:@selector(reload)];
    UIBarButtonItem *item_save = [[UIBarButtonItem alloc] initWithTitle:@"操作" style:UIBarButtonItemStyleBordered target:self action:@selector(operation)];
    
    self.navigationItem.leftBarButtonItem = item_reload;
    self.navigationItem.rightBarButtonItem = item_save;
    
    [item_reload release];
    [item_save release];
    
    [V_loading add_loading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.table_acc_list = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reload];
}

#pragma mark - action

- (void)operation
{
    UIActionSheet *acts = [[UIActionSheet alloc] initWithTitle:@"操作列表"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"删除当前账号(刷初始)", @"替换056(刷初始)", @"保存当前账号", @"刷新当前账号好友", @"手动设置PAD位置", nil];
    [acts showInView:self.navigationController.view];
    [acts autorelease];
}

- (void)save
{
    NSString *path_current_account = [O_logic get_current_account_with_pad:self.path_pad_doc
                                                                  accounts:self.array_acc_list];
    
    if (!path_current_account) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"未获取到已保存的账号，请输入一个新名字："
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"好的", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = Tag_alert_save_account_new_name;
        [alert show];
        [alert autorelease];
    }
    else {
        if ([O_logic save_current_account_with_pad:self.path_pad_doc
                                           account:path_current_account]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"保存成功！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert autorelease];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"保存失败！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert autorelease];
        }
    }
    
    [V_loading remove_loadng];
}

- (void)save_new:(NSString *)name
{
    NSString *path = DOC_SAVE_PATH;
    
    path = [path stringByAppendingPathComponent:name];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    if ([O_logic save_current_account_with_pad:self.path_pad_doc
                                       account:path]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"保存成功！"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert autorelease];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"保存失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert autorelease];
    }
}

- (void)reload
{
    [self performSelector:@selector(do_reload)
               withObject:nil
               afterDelay:0.01f];
}

- (void)do_reload
{
    BOOL valid = NO;
    
    NSString *saved_path = [VC_select_path saved_path];
    if (saved_path) {
        if ([O_logic fileExistsAtPath:saved_path]) {
            saved_path = [saved_path stringByDeletingLastPathComponent];
            saved_path = [saved_path stringByAppendingPathComponent:@"Documents"];
            self.path_pad_doc = saved_path;
        }
    }
    
    if (self.path_pad_doc) {
        if ([O_logic fileExistsAtPath:self.path_pad_doc]) {
            valid = YES;
        }
    }
    
    if (!valid) {
        self.path_pad_doc = [O_logic get_pad_path];
    }
    
    self.array_acc_list = [O_logic get_account_list];
    
    if (!self.path_pad_doc) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"未获取到PAD安装地址！请检查是否已越狱且安装PAD！点击‘\"是\"手动指定该路径。（替换账号时会删除该app的Documents下的其他内容，手动指定如果错误会有风险）"
                                                       delegate:self
                                              cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = Tag_alert_manually_set_path;
        [alert show];
        [alert autorelease];
    }
    [self.table_acc_list reloadData];
    [V_loading remove_loadng];
}

- (void)refresh_friend
{
    NSString *path_026 = [self.path_pad_doc stringByAppendingPathComponent:@"data026.bin"];
    [O_logic removeItemAtPath:path_026];
    
    if ([O_logic fileExistsAtPath:path_026]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"刷新失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert autorelease];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"刷新成功！"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert autorelease];
    }
    [V_loading remove_loadng];
}

- (void)delete_current
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"删除当前账号？"
                                                   delegate:self
                                          cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alert.tag = Tag_alert_delete_current_account;
    [alert show];
    [alert autorelease];
}

- (void)do_delete_current
{
    if ([O_logic delete_current_account_with_pad:self.path_pad_doc]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"删除成功！"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert autorelease];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"删除失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert autorelease];
    }
    
    [V_loading remove_loadng];
}

- (void)load_selected
{
    if (self.index_last_select.row < self.array_acc_list.count) {
        
        NSString *path_current_account = [O_logic get_current_account_with_pad:self.path_pad_doc
                                                                      accounts:self.array_acc_list];
        
        NSString *name_account = self.array_acc_list[self.index_last_select.row];
        if (path_current_account) {
            if ([name_account isEqualToString:path_current_account.lastPathComponent]) {
                //pass
            }
            else {
                [O_logic save_current_account_with_pad:self.path_pad_doc
                                               account:path_current_account];
            }
        }
        
        
        NSString *path_account = [DOC_SAVE_PATH stringByAppendingPathComponent:name_account];
        
        if ([O_logic load_current_account_with_pad:self.path_pad_doc account:path_account]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"切换成功！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert autorelease];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"切换失败！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert autorelease];
        }
    }
    [V_loading remove_loadng];
}

- (void)exchange_056
{
    
    if ([O_logic exchange_056_with_pad:self.path_pad_doc]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"替换056成功！"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert autorelease];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"替换056失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert autorelease];
    }
    
    [V_loading remove_loadng];
}

#pragma mark - table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array_acc_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"AccCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row < self.array_acc_list.count) {
        cell.textLabel.text = self.array_acc_list[indexPath.row];
    }
    else {
        cell.textLabel.text = @"error";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = nil;
    if (indexPath.row < self.array_acc_list.count) {
        title = self.array_acc_list[indexPath.row];
    }
    
    self.index_last_select = indexPath;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:[NSString stringWithFormat:@"切换登陆账号[%@]？未保存的账号将会丢失！", title]
                                                   delegate:self
                                          cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alert.tag = Tag_alert_load_select_account;
    [alert show];
    [alert autorelease];
}

#pragma mark - alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case Tag_alert_load_select_account:
        {
            if (1 == buttonIndex) {
                [V_loading add_loading];
                [self performSelector:@selector(load_selected) withObject:nil afterDelay:0.01f];
            }
        }
            break;
        case Tag_alert_save_account_new_name:
        {
            if (1 == buttonIndex) {
                NSString *title = [alertView textFieldAtIndex:0].text;
                if ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
                    [self save_new:title];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"名字无效，请重新输入："
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alert.tag = Tag_alert_save_account_new_name;
                    [alert show];
                    [alert autorelease];
                }
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"用户取消保存。"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [alert autorelease];
            }
        }
            break;
        case Tag_alert_delete_current_account:
        {
            if (1 == buttonIndex) {
                [V_loading add_loading];
                [self performSelector:@selector(do_delete_current) withObject:nil afterDelay:0.01f];
            }
        }
            break;
        case Tag_alert_manually_set_path:
        {
            if (1 == buttonIndex) {
                [VC_select_path show_selector_with_delegate:self];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - act
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            //delete
            [self delete_current];
        }
            break;
        case 1:
        {
            //delete
            [V_loading add_loading];
            [self performSelector:@selector(exchange_056) withObject:nil afterDelay:0.01];
        }
            break;
        case 2:
        {
            //save
            [V_loading add_loading];
            [self performSelector:@selector(save) withObject:nil afterDelay:0.01f];
        }
            break;
        case 3:
        {
            //refresh friend
            [V_loading add_loading];
            [self performSelector:@selector(refresh_friend) withObject:nil afterDelay:0.01f];
        }
            break;
        case 4:
        {
            [VC_select_path save_path:nil];
            self.path_pad_doc = nil;
            [VC_select_path show_selector_with_delegate:self];
//            [self reload];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
- (void)select_path:(NSString *)path
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self reload];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
