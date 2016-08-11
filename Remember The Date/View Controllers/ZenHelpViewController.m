//
//  ZenHelpViewController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import <ZendeskSDK/ZendeskSDK.h>
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
            
            [ZDKConfig instance].userIdentity = [[ZDKJwtIdentity alloc] initWithJwtUserIdentifier:email];
            return YES;
        }
    }
    
    return NO;
}

-(void) setupSupportInformation {

    [ZDKRequests configure:^(ZDKAccount *account, ZDKRequestCreationConfig *requestCreationConfig) {
        // configgure additional info
        NSString *appVersionString = [NSString stringWithFormat:@"version_%@",
                                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];

        
        // Setting the custom form id to use the IOS Support form
        [ZDKConfig instance].ticketFormId = @62609;
        
        // adding Application Version information
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
        
        
        [ZDKConfig instance].customTicketFields = @[customeFieldApplicationVersion,
                                                    customFieldOSVersion,
                                                    customFieldDeviceModel,
                                                    customFieldDeviceMemory,
                                                    customFieldDeviceFreeSpace,
                                                    customFieldDeviceBatteryLevel];

        
        requestCreationConfig.tags = @[@"ratemyapp_ios", @"paying_customer"];
        
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        
        if(appName) {
            requestCreationConfig.additionalRequestInfo =
            [NSString stringWithFormat:@"%@-------------\nSent from %@.", requestCreationConfig.contentSeperator, appName];
        }
            
        
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat contentViewHeight = self.contentView.frame.size.height;
    CGFloat selfHeight = self.view.frame.size.height;
    if(selfHeight > contentViewHeight) {
        _scrollView.scrollEnabled = NO;
    }
    
    
}

//
//  Show support component
//
//

- (IBAction)showHelpCenter:(id)sender {
    
    if ([self setupIdentity]) {
        SaveTheDateTabBarController * tabbarController = (SaveTheDateTabBarController*)self.tabBarController;
        
        
        self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        ZDKHelpCenterOverviewContentModel *contentModel = [ZDKHelpCenterOverviewContentModel defaultContent];
        
        if([ZDKUIUtil isPad]) {
            
            [ZDKHelpCenter presentHelpCenterOverview:self withContentModel:contentModel];
            
        } else {
            
            [tabbarController hideTabbar];
            [ZDKHelpCenter pushHelpCenterOverview:self.navigationController withContentModel:contentModel];
        }

        
    }
    else {
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
        
        if([ZDKUIUtil isPad]) {
            
            self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            self.tabBarController.modalPresentationStyle = UIModalPresentationFormSheet;
            
        }
        
        [ZDKRequests presentRequestCreationWithViewController:(UIViewController*)self.tabBarController];
        
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Wait a second..." message:@"You need to go in the profile screen and setup your email ..." delegate:self cancelButtonTitle:@"OK, doing it now :)" otherButtonTitles:nil];
        [alert show];
    }

}

//
//  Rate My App component
//
// The send button feedback is disabled as the control can not be trigger programmatically
// but is driven by the configuration done on the Zendesk Mobile SDK Administration
//
//  The following code is here for demonstration purpose only.
//

- (IBAction)sendFeedback:(id)sender {
    
    if ([self setupIdentity]) {
        
         // Setup Rate My App
        [ZDKRMA configure:^(ZDKAccount *account, ZDKRMAConfigObject *config) {
            
            // configgure additional info
            NSString *versionString = [NSString stringWithFormat:@"%@ (%@)",
                                       [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                       [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
            
            NSString *appVersion = [NSString stringWithFormat:@"App version: %@", versionString];
            
            if ([ZDKBundleUtils frameworkStringsBundle] == nil) {
                [ZDKLogger w:@"Zendesk SDK Strings Bundle must be present in order to use %s", __PRETTY_FUNCTION__];
                return;
            }
            
            NSString *osVersion = [NSString stringWithFormat:@"%@ %@",
                                   [ZDKLocalization localizedStringWithKey:@"ios.ZDKAPI.request.sendFeedback.device.osVersion"],
                                   [UIDevice currentDevice].systemVersion];
            
            NSString *model = [NSString stringWithFormat:@"%@ %@",
                               [ZDKLocalization localizedStringWithKey:@"ios.ZDKAPI.request.sendFeedback.device.model"],
                               [ZDKDeviceInfo deviceType]];
            
            NSString *totalMemory = [NSString stringWithFormat:@"%@ %.f",
                                     [ZDKLocalization localizedStringWithKey:@"ios.ZDKAPI.request.sendFeedback.device.totalMemory"],
                                     [ZDKDeviceInfo totalDeviceMemory]];
            
            NSString *space = [NSString stringWithFormat:@"%@ %.2f GB",
                               [ZDKLocalization localizedStringWithKey:@"ios.ZDKAPI.request.sendFeedback.device.freeDiskspace"],
                               [ZDKDeviceInfo freeDiskspace]];
            
            NSString *batteryLevel = [NSString stringWithFormat:@"%@ %.0f%%",
                                      [ZDKLocalization localizedStringWithKey:@"ios.ZDKAPI.request.sendFeedback.device.batteryLevel"],
                                      [ZDKDeviceInfo batteryLevel]];
            
            
            
            
            
            NSString *additionalText = [NSString stringWithFormat:@"%@\n\n%@\n%@\n%@\n%@\n%@",appVersion, osVersion, model, totalMemory, space, batteryLevel];

            
            config.additionalRequestInfo = [NSString stringWithFormat:@"\n\n\n\n%@", additionalText];
        }];
        
        /////////////////////////////////////////////////////////////////////////////////////////////////////
        // OPTIONAL - Customize appearance
        /////////////////////////////////////////////////////////////////////////////////////////////////////
        
        [ZDKRMA configure:^(ZDKAccount *account, ZDKRMAConfigObject *config) {
            // set success and error dialog images images
            config.successImageName = @"rma_tick";
            config.errorImageName = @"rma_error";
        }];
        
        [ZDKRMA showAlwaysInView:self.view];
        
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Wait a second..." message:@"You need to go in the profile screen and enter your email ..." delegate:self cancelButtonTitle:@"OK, doing it now :)" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)showMyRequests:(id)sender {
    
    if ([self setupIdentity]) {
        
        SaveTheDateTabBarController * tabbarController = (SaveTheDateTabBarController*)self.tabBarController;
        
        
        if([ZDKUIUtil isPad]) {
            
            self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            [ZDKRequests presentRequestListWithViewController:self];
            
        } else {
            
            [tabbarController hideTabbar];
            [ZDKRequests pushRequestListWithNavigationController:self.navigationController layoutGuide:ZDKLayoutRespectTop];
        }

        
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Wait a second..." message:@"You need to go in the profile screen and setup your email ..." delegate:self cancelButtonTitle:@"OK, doing it now :)" otherButtonTitles:nil];
        [alert show];
    }
    
}

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
    [ZDCChat startChat:nil];
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
    
    SaveTheDateTabBarController * tabbarController = (SaveTheDateTabBarController*)self.tabBarController;
    [tabbarController showTabbar];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
