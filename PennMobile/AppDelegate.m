//
//  AppDelegate.m
//  PennMobile
//
//  Created by Sacha Best on 10/24/14.
//  Copyright (c) 2014 Penn Labs. All rights reserved.
//

#import "AppDelegate.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <Parse/Parse.h>

#import "MainViewController.h"
#import "MasterTableViewController.h"
#import "SWRevealViewController.h"
#import "PennMobile-Swift.h"

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) MasterTableViewController *masterTableViewController;
@property (nonatomic, strong) NewDiningViewController *diningVC;
@property (nonatomic, strong) SWRevealViewController *SWRevealViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [application setStatusBarStyle:UIStatusBarStyleLightContent animated:true];
    //[ParseCrashReporting enable];
    [Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_APP_SECRET];
    [PFUser enableAutomaticUser];
    // PFUser.currentUser().saveEventually();
    [[PFInstallation currentInstallation] saveEventually];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [self registerRemoteAllDevices:application];
    //[self auth];
    
    self.diningVC = [[NewDiningViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.diningVC];
    self.navController.navigationBarHidden = YES;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    [self presentSWController];
    
    
    return YES;
}

- (void)presentSWController{
    
    self.masterTableViewController = [[MasterTableViewController alloc] init];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:self.masterTableViewController];
    
    self.diningVC = [[NewDiningViewController alloc] init];
    
    UINavigationController *homeViewNavigationController = [[UINavigationController alloc] initWithRootViewController:self.diningVC];
    
    self.SWRevealViewController = [[SWRevealViewController alloc] initWithRearViewController:masterNavigationController frontViewController:homeViewNavigationController];
    
    [self.navController pushViewController:self.SWRevealViewController animated:NO];
}


- (void)registerRemoteAllDevices:(UIApplication *)application  {
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:types];
    }
    
    PFACL *defaultACL = [[PFACL alloc] init];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *c = [PFInstallation currentInstallation];
    [c setDeviceTokenFromData:deviceToken];
    [c saveEventually];
}

- (void)auth {
    NSString * keychainItemIdentifier = @"fingerprintKeychainEntry";
    NSString * keychainItemServiceName = @"org.pennlabs.PennMobile";
    
    // The content of the password is not important.
    
    NSData * pwData = [@"fingerprint" dataUsingEncoding:NSUTF8StringEncoding];
    // Create the keychain entry attributes.
    NSMutableDictionary	* attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        (__bridge id)(kSecClassGenericPassword), kSecClass,
                                        keychainItemIdentifier, kSecAttrAccount,
                                        keychainItemServiceName, kSecAttrService, nil];
    
    // Require a fingerprint scan or passcode validation when the keychain entry is read.
    // Apple also offers an option to destroy the keychain entry if the user ever removes the
    // passcode from his iPhone, but we don't need that option here.
    CFErrorRef accessControlError = NULL;
    SecAccessControlRef accessControlRef = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, kSecAccessControlUserPresence, &accessControlError);
    if (accessControlRef == NULL || accessControlError != NULL) {
        NSLog(@"Cannot create SecAccessControlRef to store a password with identifier “%@” in the key chain: %@.", keychainItemIdentifier, accessControlError);
        return;
    }
    
    attributes[(__bridge id)kSecAttrAccessControl] = (__bridge id)accessControlRef;
    
    // In case this code is executed again and the keychain item already exists we want an error code instead of a fingerprint scan.
    attributes[(__bridge id)kSecUseNoAuthenticationUI] = @YES;
    attributes[(__bridge id)kSecValueData] = pwData;
    
    CFTypeRef result;
    OSStatus osStatus = SecItemAdd((__bridge CFDictionaryRef)attributes, &result);
    
    if (osStatus != noErr)
    {
        NSError * error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:osStatus userInfo:nil];
        
        NSLog(@"Adding generic password with identifier “%@” to keychain failed with OSError %d: %@.", keychainItemIdentifier, (int)osStatus, error);
    }
    // Determine a string which the device will display in the fingerprint view explaining the reason for the fingerprint scan.
    NSString * secUseOperationPrompt = @"For PennKey protected resources. ";
    
    // The keychain operation shall be performed by the global queue. Otherwise it might just nothing happen.
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        // Create the keychain query attributes using the values from the first part of the code.
        NSMutableDictionary * query = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(__bridge id)(kSecClassGenericPassword), kSecClass, keychainItemIdentifier, kSecAttrAccount, keychainItemServiceName, kSecAttrService, secUseOperationPrompt, kSecUseOperationPrompt, nil];
        
        // Start the query and the fingerprint scan and/or device passcode validation
        CFTypeRef result = nil;
        OSStatus userPresenceStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
        
        // Ignore the found content of the key chain entry (the dummy password) and only evaluate the return code.
        if (noErr == userPresenceStatus) {
            NSLog(@"Fingerprint or device passcode validated.");
        }
        else {
            NSLog(@"Fingerprint or device passcode could not be validated. Status %d.", (int) userPresenceStatus);
        }
        
        // To process the result at this point there would be a call to delegate method which
        // would do its work like GUI operations in the main queue. That means it would start
        // with something like:
        dispatch_async(dispatch_get_main_queue(), ^{
            // put code here after making a splash scene similar to Robinhood
        });
    });
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
