//
//  AppDelegate.m
//  PadMgr
//
//  Created by user_admin on D/23/2013.
//  Copyright (c) 2013 comcsoft. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:NO];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    ViewController *vc_ = [[[ViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    UINavigationController *nc_ = [[[UINavigationController alloc] initWithRootViewController:vc_] autorelease];
    self.window.rootViewController = nc_;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    exit(0);
}

- (void)dealloc
{
    [_window release], _window = nil;
    [super dealloc];
}

@end
