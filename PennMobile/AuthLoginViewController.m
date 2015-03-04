//
//  AuthLoginViewController.m
//  PennMobile
//
//  Created by Sacha Best on 3/3/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "AuthLoginViewController.h"

@interface AuthLoginViewController ()

@end

@implementation AuthLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:AUTH_URL]];
    [_webView loadRequest:req];
    _webView.scalesPageToFit = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSURL *u = [webView.request mainDocumentURL];
    NSLog(@"Loaded url: %@", u);
    if ([u.host isEqualToString:@"api.pennlabs.org"]) {
        // store the auth token
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSString *query = u.query;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        for (NSString *param in [query componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if ([elts count] < 2) continue;
            [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
        }
        [def setObject:params[@"token"] forKey:@"token"];
        [def setObject:params[@"expiry"] forKey:@"expiry"];
    }
}

+ (void)auth {
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
    NSString * secUseOperationPrompt = @"Authenticate for server login";
    
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
           
        });
    });
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
