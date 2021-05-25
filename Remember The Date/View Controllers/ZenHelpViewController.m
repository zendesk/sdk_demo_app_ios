//
//  ZenHelpViewController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import <SupportSDK/SupportSDK.h>
#import <SupportProvidersSDK/SupportProvidersSDK.h>
#import <ZendeskCoreSDK/ZendeskCoreSDK-Swift.h>
#import <AnswerBotSDK/AnswerBotSDK-Swift.h>
#import <MessagingAPI/MessagingAPI.h>
#import <MessagingSDK/MessagingSDK.h>
#import <ChatSDK/ChatSDK.h>
#import <ChatProvidersSDK/ChatProvidersSDK.h>

#import "ZenHelpViewController.h"
#import "SaveTheDateTabBarController.h"


@interface ZenHelpViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@end

@implementation ZenHelpViewController

- (BOOL) setupIdentity {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults stringForKey:@"userName"]) {
        NSString *email = [defaults stringForKey:@"email"];
        
        if (email.length > 0) {
            id<ZDKObjCIdentity> userIdentity = [[ZDKObjCJwt alloc] initWithToken:email];
            [[ZDKZendesk instance] setIdentity:userIdentity];

            return YES;
        }
    }
    return NO;
}

-(ZDKRequestUiConfiguration*) setupSupportInformation {
    ZDKRequestUiConfiguration * config = [ZDKRequestUiConfiguration new];
    
    NSString *appVersionString = [NSString stringWithFormat:@"version_%@",
                                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    config.ticketFormID = @62609;

    ZDKCustomField *customeFieldApplicationVersion = [[ZDKCustomField alloc] initWithFieldId:@24328555 value:appVersionString];
    //OS version
    ZDKCustomField *customFieldOSVersion = [[ZDKCustomField alloc] initWithFieldId:@24273979 value:[UIDevice currentDevice].systemVersion];
    //Device model
    ZDKCustomField *customFieldDeviceModel = [[ZDKCustomField alloc] initWithFieldId:@24273989 value:[ZDKDeviceInfo deviceType]];
    //Device memory
    NSString *deviceMemory = [NSString stringWithFormat:@"%f MB", [ZDKDeviceInfo totalDeviceMemory]];
    ZDKCustomField *customFieldDeviceMemory = [[ZDKCustomField alloc] initWithFieldId:@24273999 value:deviceMemory];
    //Device free space
    NSString *deviceFreeSpace = [NSString stringWithFormat:@"%f GB", [ZDKDeviceInfo freeDiskspace]];
    ZDKCustomField *customFieldDeviceFreeSpace = [[ZDKCustomField alloc] initWithFieldId:@24274009 value:deviceFreeSpace];
    //Device battery level
    NSString *deviceBatteryLevel = [NSString stringWithFormat:@"%f", [ZDKDeviceInfo batteryLevel]];
    ZDKCustomField *customFieldDeviceBatteryLevel = [[ZDKCustomField alloc] initWithFieldId:@24274019 value:deviceBatteryLevel];

    config.customFields =  @[customeFieldApplicationVersion,
                       customFieldOSVersion,
                       customFieldDeviceModel,
                       customFieldDeviceMemory,
                       customFieldDeviceFreeSpace,
                       customFieldDeviceBatteryLevel];
    
    config.tags = @[@"ratemyapp_ios", @"paying_customer"];

    return config;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat contentViewHeight = self.contentView.frame.size.height;
    CGFloat selfHeight = self.view.frame.size.height;
    if(selfHeight > contentViewHeight) {
        _scrollView.scrollEnabled = NO;
    }
    self.helpCenterButton.titleLabel.font = [UIFont fontWithName:@"SFPro-Text-Semibold" size:15.0];
    self.contactUsButton.titleLabel.font = [UIFont fontWithName:@"SFPro-Text-Semibold" size:15.0];
    self.myTicketsButton.titleLabel.font = [UIFont fontWithName:@"SFPro-Text-Semibold" size:15.0];
    self.startChatButton.titleLabel.font = [UIFont fontWithName:@"SFPro-Text-Semibold" size:15.0];
    
    self.helpCenterButton.layer.cornerRadius = 20.0;
    self.contactUsButton.layer.cornerRadius = 20.0;
    self.myTicketsButton.layer.cornerRadius = 20.0;
    self.startChatButton.layer.cornerRadius = 20.0;
    
    if ((self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
        && (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular)) {
        self.topLabel.font = [UIFont fontWithName:@"SFProText" size:17.0];
        self.topLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        self.topLabel.font = [UIFont fontWithName:@"SFProText" size:13.0];
    }
}

///  Show support component
- (IBAction)showHelpCenter:(id)sender {
    
    if ([self setupIdentity]) {
        if([ZDKUIUtil isPad]) {
            ZDKRequestUiConfiguration * config = [self setupSupportInformation];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[config]]];
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        } else {
            [self.navigationController pushViewController:[ZDKHelpCenterUi buildHelpCenterOverviewUi] animated:YES];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait a second..."
                                                        message:@"You need to go in the profile screen and setup your email ..."
                                                       delegate:self
                                              cancelButtonTitle:@"OK, doing it now :)"
                                              otherButtonTitles:nil];
        [alert show];
    }

}

/// Request Creation component
- (IBAction)contactSupport:(id)sender {
    
    if ([self setupIdentity]) {
        
        self.navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        ZDKRequestUiConfiguration *config = [self setupSupportInformation];
        ZDKAnswerBotEngine *abEngine = [ZDKAnswerBotEngine engineAndReturnError:nil];
        ZDKSupportEngine *supportEngine = [ZDKSupportEngine engineAndReturnError:nil];
        NSArray<id <ZDKEngine>> *engines = @[(id <ZDKEngine>)abEngine, (id <ZDKEngine>)supportEngine];
        UIViewController *requestController = [[ZDKMessaging instance] buildUIWithEngines:engines configs:@[config] error:nil];
    
        [self.navigationController pushViewController:requestController animated:YES];
        
    } else {
        [[self alertView] show];
    }

}

///  Show Request List component
- (IBAction)showMyRequests:(id)sender {
    
    if ([self setupIdentity]) {
        ZDKRequestUiConfiguration * config = [self setupSupportInformation];
        UIViewController * requestListController = [ZDKRequestUi buildRequestListWith:@[config]];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:requestListController];
        
        if([ZDKUIUtil isPad]) {
            
            self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
           
            [self.navigationController presentViewController:navController animated:YES completion:nil];
            
        } else {
            self.navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self.navigationController pushViewController:requestListController animated:YES];
        }
    } else {
        [[self alertView] show];
    }
    
}

///  Show Chat component
- (IBAction)showChat:(id)sender {
    // update the visitor info before starting the chat
    NSString *visitorEmail = [self userEmail];

    if (visitorEmail) {
        ZDKVisitorInfo *visitorInfo = [[ZDKVisitorInfo alloc] initWithName:[self userName]
                                                                     email:[self userEmail]
                                                               phoneNumber:@""];
        [[[ZDKChat instance] profileProvider] setVisitorInfo:visitorInfo
                                                  completion:^(ZDKVisitorInfo *visitor, NSError *error) { }];
        ZDKChat.instance.configuration.visitorInfo = visitorInfo;
    }
    ZDKChatConfiguration *config = [ZDKChatConfiguration new];
    config.preChatFormConfiguration = [[ZDKChatFormConfiguration alloc] initWithName:ZDKFormFieldStatusOptional
                                                                               email:ZDKFormFieldStatusOptional
                                                                         phoneNumber:ZDKFormFieldStatusHidden
                                                                          department:ZDKFormFieldStatusOptional];
    ZDKMessagingConfiguration *messagingConfig = [ZDKMessagingConfiguration new];
    messagingConfig.isMultilineResponseOptionsEnabled = YES;
    messagingConfig.name = @"RTD2";
    ZDKAnswerBotEngine *abEngine = [ZDKAnswerBotEngine engineAndReturnError:nil];
    ZDKChatEngine *chatEngine = [ZDKChatEngine engineAndReturnError:nil];
    NSArray<id <ZDKEngine>> *engines = @[(id <ZDKEngine>)abEngine, (id <ZDKEngine>)chatEngine];

    UIViewController *viewController = [[ZDKMessaging instance] buildUIWithEngines:engines configs:@[messagingConfig, config] error:nil];

    // present as new modal using global pre-chat config and whatever visitor info has been persisted
    [self.navigationController pushViewController:viewController animated:YES];
}

-(NSString *) userEmail {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults stringForKey:@"userName"] != nil) {
        NSString* email = [defaults stringForKey:@"email"];
        if ([email length] > 0) {
            return email;
        }
    }
    return nil;
}

- (NSString *) userName {
    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"userName"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //
    // Setup the support information
    //
    [self setupSupportInformation];

    SaveTheDateTabBarController * tabbarController = (SaveTheDateTabBarController*)self.tabBarController;
    [tabbarController showTabbar];
}

/// Returns an alertView to display
-(UIAlertView*)alertView {
    return [[UIAlertView alloc] initWithTitle:@"Wait a second..."
                                      message:@"You need to go in the profile screen and setup your email ..."
                                     delegate:self
                            cancelButtonTitle:@"OK, doing it now :)"
                            otherButtonTitles:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
