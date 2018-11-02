//
//  AppDelegate.m
//  Remember The Date
//
//  Created by Zendesk on 10/9/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import "AppDelegate.h"
#import "NSData+RememberTheDate.h"
@import ZendeskSDK;
@import ZendeskCoreSDK;
#import <ZDCChat/ZDCChat.h>

#define RED_COLOR [UIColor colorWithRed:232.0f/255.f green:42.0f/255.0f blue:42.0f/255.0f alpha:1.0f]
#define ORANGE_COLOR [UIColor colorWithRed:253.0f/255.f green:144.0f/255.0f blue:38.0f/255.0f alpha:1.0f]
#define ORANGE_COLOR_40 [UIColor colorWithRed:253.0f/255.f green:144.0f/255.0f blue:38.0f/255.0f alpha:0.4f]

#define TEXT_COLOR [UIColor colorWithRed:150.0f/255.f green:110.0f/255.0f blue:90.0f/255.0f alpha:1.0f]
#define TEXT_COLOR_40 [UIColor colorWithRed:150.0f/255.f green:110.0f/255.0f blue:90.0f/255.0f alpha:.4f]

#define PLACEHOLDER_COLOR [UIColor colorWithRed:217.0f/255.f green:205.0f/255.0f blue:200.0f/255.0f alpha:1.0f]
#define NAVBAR_COLOR [UIColor colorWithRed:240.0f/255.f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]
#define EMAIL_COLOR [UIColor colorWithRed:214.0f/255.f green:214.0f/255.0f blue:214.0f/255.0f alpha:1.0f]

static NSString * APP_ID = @"e5dd7520b178e21212f5cc2751a28f4b5a7dc76698dc79bd";
static NSString * ZENDESK_URL = @"https://rememberthedate.zendesk.com";
static NSString * CLIENT_ID = @"client_for_rtd_jwt_endpoint";

NSString * const APNS_ID_KEY = @"APNS_ID_KEY";

@interface AppDelegate ()

@end

@implementation AppDelegate


-(void) setupSDKStyle {

    // status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // nav bar
    NSDictionary *navbarAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor] ,NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[[UIColor alloc] initWithRed:0 green:(188.0/255.0) blue:(212.0/255.0) alpha:1.0]];

    ZDKTheme.currentTheme.primaryColor = [[UIColor alloc] initWithRed:0 green:(188.0/255.0) blue:(212.0/255.0) alpha:1.0];

    // chat SDK
    [[ZDCChatOverlay appearance] setInsets:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(75.0f, 15.0f, 70.0f, 15.0f)]];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // sync the default
    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];

    // Visual setup
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UITextView appearance] setTintColor:[[UIColor alloc] initWithRed:0 green:(188.0/255.0) blue:(212.0/255.0) alpha:1.0]];
    [[UITabBar appearance] setSelectedImageTintColor: [[UIColor alloc] initWithRed:0 green:(188.0/255.0) blue:(212.0/255.0) alpha:1.0]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Request Local Notifications
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }

    // Register for remote notfications    
    if ([UIApplication instancesRespondToSelector:@selector(registerForRemoteNotifications)]) {
        
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        
    } else if ([UIApplication instancesRespondToSelector:@selector(registerForRemoteNotificationTypes:)]) {
        
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        
        [application registerForRemoteNotificationTypes:types];
        
#pragma clang diagnostic pop
    }
    //
    // Enable logging for debug builds
    //
    
#ifdef DEBUG
    [ZDKCoreLogger setEnabled:YES];
#else
    [ZDKCoreLogger setEnabled:NO];
#endif

    //
    // Initialize the Zendesk SDK
    //
    [ZDKZendesk initializeWithAppId:@"e5dd7520b178e21212f5cc2751a28f4b5a7dc76698dc79bd" clientId:@"client_for_rtd_jwt_endpoint" zendeskUrl:@"https://rememberthedate.zendesk.com"];
    [ZDKSupport initializeWithZendesk:[ZDKZendesk instance]];

    
    //
    // Style the SDK
    //
    
    [self setupSDKStyle];

    //
    // Initialise the chat SDK
    //
    [ZDCChat initializeWithAccountKey:@"2qNzXIeOGKD0LbLOWgAclb72G3LLfOHK"];

    
    //
    //  The rest of the Mobile SDK code can be found in ZenHelpViewController.m
    //
    
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    //
    // Register the Support SDK for push notifications
    //

    NSString *identifier = [deviceToken deviceIdentifier];
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:APNS_ID_KEY];
    
    if ([[ZDKZendesk instance] objCIdentity] != nil ) {
        
        NSString * locale = [[NSLocale preferredLanguages] firstObject];
        [[[ZDKPushProvider alloc] initWithZendesk:[ZDKZendesk instance]] registerWithDeviceIdentifier:identifier locale:locale completion:^(NSString * _Nullable registrationResponse, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Couldn't register device: %@. Error: %@ in %@", identifier, error, self.class);
            } else if (registrationResponse) {
                
                NSLog(@"Successfully registered device: %@ in %@", identifier, self.class);
            }
        }];
        
    }
    
    //
    // Register the Chat SDK for push notifications
    //
    [ZDCChat setPushToken:deviceToken];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Recieved push payload:\n%@", userInfo);
    NSString * requestID = userInfo[@"zendesk_sdk_request_id"];
    if (requestID != nil) {
        [self handleSupportPush:requestID];
        completionHandler;

    } else {
        [self handleChatPush:userInfo];
        completionHandler;
    }
    
}

- (void) handleSupportPush:(NSString *)requestID {
    if ([[ZDKSupport instance] refreshRequestWithRequestId:requestID]) {
        return;
    } else {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        UIViewController * controller = window.rootViewController;
        
        UIViewController * sdkController = [ZDKRequestUi buildRequestUiWithRequestId:requestID];
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:sdkController];
        
        [controller presentViewController:navController animated:true completion:nil];
    }
}

- (void) handleChatPush:(NSDictionary *)userInfo {
    [ZDCChat didReceiveRemoteNotification:userInfo];
}

@end
