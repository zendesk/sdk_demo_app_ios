//
//  AppDelegate.m
//  Remember The Date
//
//  Created by Zendesk on 10/9/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import "AppDelegate.h"
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


@interface AppDelegate ()

@end

@implementation AppDelegate



-(void) setupSDKStyle {

    // status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // nav bar
    NSDictionary *navbarAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor] ,NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:RED_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarAttributes];
    
    
    [[ZDKCreateRequestView appearance] setPlaceholderTextColor:TEXT_COLOR_40];
    [[ZDKCreateRequestView appearance] setTextEntryColor:TEXT_COLOR];
    
    [[ZDKUITextView appearance] setTintColor:RED_COLOR];
    
    [[ZDKCreateRequestView appearance] setTextEntryFont:[UIFont fontWithName:@"Helvetica" size:16]];
    
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [spinner setTintColor:RED_COLOR];
    [spinner setColor:RED_COLOR];
    
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
    
    
    
    
    //
    // Initialize the sdk
    //
    
    // Note:    If you do need to display the request list to your users, you will need to setup JWT until version 1.0
    // ----     If you don't need tthe request list, use the short initialize method (which is not deprecated)
    //          [[ZDKConfig instance] initializeWithAppId:(NSString *) andZendeskUrl:(NSString *)]
    //
    
    [[ZDKConfig instance] initializeWithAppId:@"e5dd7520b178e21212f5cc2751a28f4b5a7dc76698dc79bd"
             zendeskUrl:@"https://rememberthedate.zendesk.com"
                  andClientId:@"client_for_rtd_jwt_endpoint"];
    
    #ifdef DEBUG
        [ZDKLogger enable:YES];
    #else
        [ZDKLogger enable:NO];
    #endif
    
    
    //
    // Style the SDK
    //
    
    [self setupSDKStyle];
    
    //
    //  The rest of the Mobile SDK code can be found in ZenHelpViewController.m
    //
    
    return YES;
}

@end
