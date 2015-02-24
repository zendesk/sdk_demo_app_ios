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

@property (nonatomic, strong) ZDKJwtIdentity *identity;

@end

@implementation ZenHelpViewController


- (void) setupIdentity {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults stringForKey:@"userName"]) {
        NSString *email = [defaults stringForKey:@"email"];
        if ( [email length] > 0) {
            _identity = [[ZDKJwtIdentity alloc] initWithJwtUserIdentifier:email];
            [ZDKConfig instance].userIdentity = _identity;
        }
    } else {
        _identity = nil;
    }
}

-(void) setupSupportInformation {

    [ZDKRequests configure:^(ZDKAccount *account, ZDKRequestCreationConfig *requestCreationConfig) {
        // configgure additional info
        NSString *versionString = [NSString stringWithFormat:@"%@ (%@)",
                                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        
        NSString *appVersion = [NSString stringWithFormat:@"App version: %@", versionString];
        
        NSString *additionalText = [NSString stringWithFormat:@"%@\n\n%@",
                         appVersion,
                         [ZDKDeviceInfo deviceInfoString]];

        requestCreationConfig.tags = @[@"ios"];
        requestCreationConfig.additionalRequestInfo = [NSString stringWithFormat:@"\n\n\n\n%@", additionalText];
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
    
    if (_identity) {
        SaveTheDateTabBarController * tabbarController = (SaveTheDateTabBarController*)self.tabBarController;
        [tabbarController hideTabbar];
        
        [ZDKHelpCenter showHelpCenterWithNavController:self.navigationController];
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
    
    if (_identity) {
        [ZDKRequests showRequestCreationWithNavController:self.navigationController
                                              withSuccess:^(NSData *data) {
                                                  
                                                  // do something here if you want to...
                                                  
                                              } andError:^(NSError *err) {
                                                  
                                                  // do something here if you want to...
                                              }];

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
    
    if (_identity) {
        
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
    
    if (_identity) {
        
        SaveTheDateTabBarController * tabbarController = (SaveTheDateTabBarController*)self.tabBarController;
        [tabbarController hideTabbar];
        
        RequestListViewController *vc = [RequestListViewController new];
        [self.navigationController pushViewController:vc animated:YES];
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
    [self setupIdentity];
    
    SaveTheDateTabBarController * tabbarController = (SaveTheDateTabBarController*)self.tabBarController;
    [tabbarController showTabbar];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
