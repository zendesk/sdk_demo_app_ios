//
//  SaveTheDateTabBarController.h
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SaveTheDateTabBarController : UITabBarController <CLLocationManagerDelegate>

-(void) hideTabbar;
-(void) showTabbar;

@end
