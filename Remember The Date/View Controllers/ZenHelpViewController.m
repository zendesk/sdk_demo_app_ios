//
//  ZenHelpViewController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import <ZendeskSDK/ZendeskSDK.h>

#import "ZenHelpViewController.h"
#import "RequestListViewController.h"
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
        
        
        
        NSString *additionalText = [ZDKDeviceInfo deviceInfoString];

        
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
        
        if([ZDKUIUtil isPad]) {
            
            [ZDKHelpCenter presentHelpCenterWithNavController:self.navigationController];
            
        } else {
            
            [tabbarController hideTabbar];
            [ZDKHelpCenter showHelpCenterWithNavController:self.navigationController layoutGuide:ZDKLayoutRespectTop];
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
        
        [ZDKRequests showRequestCreationWithNavController:(UINavigationController*)self.tabBarController];
        
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
            
            
            NSString *additionalText = [NSString stringWithFormat:@"%@\n\n%@",
                                        appVersion,
                                        [ZDKDeviceInfo deviceInfoString]];

            
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
            [ZDKRequests presentRequestListWithNavController:self.navigationController];
            
        } else {
            
            [tabbarController hideTabbar];
            [ZDKRequests showRequestListWithNavController:self.navigationController layoutGuide:ZDKLayoutRespectTop];
        }

        
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Wait a second..." message:@"You need to go in the profile screen and setup your email ..." delegate:self cancelButtonTitle:@"OK, doing it now :)" otherButtonTitles:nil];
        [alert show];
    }
    
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
