//
//  AppDelegate.m
//  Remember The Date
//
//  Created by Zendesk on 10/9/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import "AppDelegate.h"
#import "NSData+RememberTheDate.h"
#import <ZendeskSDK/ZendeskSDK.h>
#import <ZendeskSDK/ZDKSupportView.h>

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

    
    [[ZDKCreateRequestView appearance] setPlaceholderTextColor:TEXT_COLOR_40];
    [[ZDKCreateRequestView appearance] setTextEntryColor:TEXT_COLOR];
    
    
    [[ZDKCreateRequestView appearance] setTextEntryFont:[UIFont fontWithName:@"Helvetica" size:16]];
    
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    [spinner setColor:RED_COLOR];
    
    if ([ZDKUIUtil isNewerVersion:@6]){
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor:RED_COLOR];
        [[ZDKUITextView appearance] setTintColor:RED_COLOR];
        [spinner setTintColor:RED_COLOR];
    }
    
    [[ZDKCreateRequestView appearance] setSpinner:(id<ZDKSpinnerDelegate>)spinner];
    [[ZDRequestListLoadingTableCell appearance] setSpinner:(id<ZDKSpinnerDelegate>)spinner];
    
    [[ZDKRequestListTableCell appearance] setLeftInset:@20];
    [[ZDKRequestListTableCell appearance] setUnreadColor:RED_COLOR];
    
    //Temp fix for 1.1 appearance issue
    [[ZDKEndUserCommentTableCell appearance] setCellBackground:[UIColor colorWithWhite:0.967f alpha:1.0f]];
    [[ZDKAgentCommentTableCell appearance] setCellBackground:[UIColor whiteColor]];
    

    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // sync the default
    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];

    // Visual setup
    
    [[UITabBar appearance] setSelectedImageTintColor: [UIColor colorWithRed:0.38 green:0.85 blue:0.82 alpha:1.0]];
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
    }
    //
    // Enable logging for debug builds
    //
    
#ifdef DEBUG
    [ZDKLogger enable:YES];
#else
    [ZDKLogger enable:NO];
#endif

    //
    // Initialize the sdk
    //
    
    [[ZDKConfig instance] initializeWithAppId:@"e5dd7520b178e21212f5cc2751a28f4b5a7dc76698dc79bd"
                                   zendeskUrl:@"https://rememberthedate.zendesk.com"
                                  andClientId:@"client_for_rtd_jwt_endpoint"];
    
    //
    // Style the SDK
    //
    
    [self setupSDKStyle];
    
    //
    //  The rest of the Mobile SDK code can be found in ZenHelpViewController.m
    //
    
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    //
    // Register SDK for push notifications
    //

    NSString *identifier = [deviceToken deviceIdentifier];
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:APNS_ID_KEY];
    
    if([[ZDKConfig instance] userIdentity] != nil) {

    [[ZDKConfig instance] enablePush:identifier callback:^(ZDKPushRegistrationResponse *registrationResponse, NSError *error) {

        if (error) {

            [ZDKLogger log:@"Couldn't register device: %@. Error: %@ in %@", identifier, error, self.class];

        } else if (registrationResponse) {

            [ZDKLogger log:@"Successfully registered device: %@ in %@", identifier, self.class];
        }
    }];
        
    }

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [ZDKPushUtil handlePush:userInfo
             forApplication:application
          presentationStyle:UIModalPresentationFormSheet
                layoutGuide:ZDKLayoutRespectTop
                  withAppId:APP_ID
                 zendeskUrl:ZENDESK_URL
                   clientId:CLIENT_ID];
    
}
@end
