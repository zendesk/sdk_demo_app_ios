//
//  SaveTheDateTabBarController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import "SaveTheDateTabBarController.h"
#import <ZendeskSDK/ZendeskSDK.h>

#define BUTTON_ADD_TAG 100

@interface SaveTheDateTabBarController ()

@property (nonatomic, strong) CLLocationManager * locationManager;

@end

@implementation SaveTheDateTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self startLocationManager];
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.title = nil;
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }];
    
    UIButton    *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    plusButton.backgroundColor  = [UIColor whiteColor];
    [plusButton setImage:[UIImage imageNamed:@"plus_icon"] forState:UIControlStateNormal];
    [plusButton setImage:[UIImage imageNamed:@"plus_active_icon"] forState:UIControlStateHighlighted];
    plusButton.layer.cornerRadius   = plusButton.currentImage.size.width/2;
    
    [plusButton addTarget:self action:@selector(didTapAdd:) forControlEvents:UIControlEventTouchUpInside];
    [plusButton setTag:BUTTON_ADD_TAG];
    [self.view addSubview:plusButton];
    
    [self.view viewWithTag:BUTTON_ADD_TAG].translatesAutoresizingMaskIntoConstraints = NO;
    
    int constSpacing = 0;
    //Plus button padding for the iphone
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        constSpacing = -13;
    }
    
    //Adding horizontal constraint for plus button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:[self.view viewWithTag:BUTTON_ADD_TAG] attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    //Adding vertical constraint for plus button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:[self.view viewWithTag:BUTTON_ADD_TAG] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:constSpacing]];
    
    
    [self.tabBar setClipsToBounds:YES];

        
}


- (void) startLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager requestAlwaysAuthorization];
    
    
    [_locationManager startUpdatingLocation];
}


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)location {
    NSLog(@"NewLocation %f %f", [location lastObject].coordinate.latitude, [location lastObject].coordinate.longitude);
    NSString * locString = @"53.3344707,-6.2628707";//[NSString stringWithFormat:@"%f,%f", [location lastObject].coordinate.latitude, [location lastObject].coordinate.longitude];
    ZDKCustomField * loc = [[ZDKCustomField alloc] initWithFieldId:@6963343 andValue:locString];
    
    [ZDKConfig instance].customTicketFields = @[loc];
}


- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}


-(void) hideTabbar {
    [self.tabBar setHidden:YES];
    [[self.view viewWithTag:BUTTON_ADD_TAG] setHidden:YES];
}

-(void) showTabbar {
    [self.tabBar setHidden:NO];
    [[self.view viewWithTag:BUTTON_ADD_TAG] setHidden:NO];
}

- (void)didTapAdd:(id)sender
{
    UINavigationController  *addController  = [self.storyboard instantiateViewControllerWithIdentifier:@"newDate"];
    [self presentViewController:addController animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
