//
//  ZenHelpViewController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import <ZendeskSDK/ZendeskSDK.h>
#import <ZendeskCoreSDK/ZendeskCoreSDK-Swift.h>
#import <AnswerBotSDK/AnswerBotSDK-Swift.h>

#import <ZDCChat/ZDCChat.h>

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
        
        if ( email.length > 0) {
            
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
    
    ZDKCustomField *customeFieldApplicationVersion = [[ZDKCustomField alloc] initWithFieldId:@24328555 andValue:appVersionString];
    //OS version
    ZDKCustomField *customFieldOSVersion = [[ZDKCustomField alloc] initWithFieldId:@24273979
                                                                          andValue:[UIDevice currentDevice].systemVersion];
    //Device model
    ZDKCustomField *customFieldDeviceModel = [[ZDKCustomField alloc] initWithFieldId:@24273989
                                                                            andValue:[ZDKDeviceInfo deviceType]];
    //Device memory
    NSString *deviceMemory = [NSString stringWithFormat:@"%f MB", [ZDKDeviceInfo totalDeviceMemory]];
    ZDKCustomField *customFieldDeviceMemory = [[ZDKCustomField alloc] initWithFieldId:@24273999
                                                                             andValue:deviceMemory];
    //Device free space
    NSString *deviceFreeSpace = [NSString stringWithFormat:@"%f GB", [ZDKDeviceInfo freeDiskspace]];
    ZDKCustomField *customFieldDeviceFreeSpace = [[ZDKCustomField alloc] initWithFieldId:@24274009 andValue:deviceFreeSpace];
    //Device battery level
    NSString *deviceBatteryLevel = [NSString stringWithFormat:@"%f", [ZDKDeviceInfo batteryLevel]];
    ZDKCustomField *customFieldDeviceBatteryLevel = [[ZDKCustomField alloc] initWithFieldId:@24274019 andValue:deviceBatteryLevel];
    
    config.fields =  @[customeFieldApplicationVersion,
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
    self.answerBotbutton.titleLabel.font = [UIFont fontWithName:@"SFPro-Text-Semibold" size:15.0];
    
    self.helpCenterButton.layer.cornerRadius = 20.0;
    self.contactUsButton.layer.cornerRadius = 20.0;
    self.myTicketsButton.layer.cornerRadius = 20.0;
    self.startChatButton.layer.cornerRadius = 20.0;
    self.answerBotbutton.layer.cornerRadius = 20.0;
    
    if ((self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)
        && (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular)) {
        self.topLabel.font = [UIFont fontWithName:@"SFProText" size:17.0];
        self.topLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        self.topLabel.font = [UIFont fontWithName:@"SFProText" size:13.0];
    }
}

//
//  Show support component
//
//

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
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Wait a second..." message:@"You need to go in the profile screen and setup your email ..." delegate:self cancelButtonTitle:@"OK, doing it now :)" otherButtonTitles:nil];
        [alert show];
    }

}

//
//  Request Creation component
//
//

- (IBAction)contactSupport:(id)sender {
    
    if ([self setupIdentity]) {
        
        self.navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        ZDKRequestUiConfiguration * config = [self setupSupportInformation];
        UIViewController * requestController = [ZDKRequestUi buildRequestUiWith:@[config]];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:requestController];
        
        if([ZDKUIUtil isPad]) {
            
            self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            self.tabBarController.modalPresentationStyle = UIModalPresentationFormSheet;
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            
        }
    
        [self.navigationController presentViewController:navController animated:YES completion:nil];
        
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Wait a second..." message:@"You need to go in the profile screen and setup your email ..." delegate:self cancelButtonTitle:@"OK, doing it now :)" otherButtonTitles:nil];
        [alert show];
    }

}

//
//  Show Request List component
//
//
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
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Wait a second..." message:@"You need to go in the profile screen and setup your email ..." delegate:self cancelButtonTitle:@"OK, doing it now :)" otherButtonTitles:nil];
        [alert show];
    }
    
}

//
//  Show Chat component
//
//

- (IBAction)showChat:(id)sender {

    // update the visitor info before starting the chat

    NSString *visitorEmail = [self userEmail];

    if (visitorEmail) {

        [ZDCChat updateVisitor:^(ZDCVisitorInfo *visitor) {

            visitor.name = [self userName];
            visitor.email = [self userEmail];
        }];
    }

    // present as new modal using global pre-chat config and whatever visitor info has been persisted
    [ZDCChat startChat:^(ZDCConfig *config) {
        config.preChatDataRequirements.department = ZDCPreChatDataOptional;
        config.preChatDataRequirements.message = ZDCPreChatDataOptional;
    }];
}

-(NSString *) userEmail {

    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];

    if ([defaults stringForKey:@"userName"] != nil)
    {
        NSString* email = [defaults stringForKey:@"email"];
        if ([email length]>0) {
            return email;
        }
    }

    return nil;
}

//
//  Show Answer Bot Component
//
//
- (IBAction)showAnswerBot:(id)sender {
    if ([self setupIdentity]) {

        self.navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

        UIViewController * answerBotController = [ZDKAnswerBotUI buildAnswerBotUI];
        [self.navigationController pushViewController:answerBotController animated:true];

    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Wait a second..." message:@"You need to go in the profile screen and setup your email ..." delegate:self cancelButtonTitle:@"OK, doing it now :)" otherButtonTitles:nil];
        [alert show];
    }

}


- (NSString *) userName {

    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"userName"];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //
    // Setup the support information
    //
    [self setupSupportInformation];

    // TODO: This is a workaround for a bug in Answer bot and should be removed in the next version
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[[UIColor alloc] initWithRed:0 green:(188.0/255.0) blue:(212.0/255.0) alpha:1.0]];
    
    SaveTheDateTabBarController * tabbarController = (SaveTheDateTabBarController*)self.tabBarController;
    [tabbarController showTabbar];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
