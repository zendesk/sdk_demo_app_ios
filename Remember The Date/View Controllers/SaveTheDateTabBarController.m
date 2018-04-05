//
//  SaveTheDateTabBarController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import "SaveTheDateTabBarController.h"

#define BUTTON_ADD_TAG 100

@interface SaveTheDateTabBarController ()

@end

@implementation SaveTheDateTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.title = nil;
//        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }];
    
    
    [self.tabBar setClipsToBounds:YES];
//    [self.tabBar setTintColor:[[UIColor alloc] initWithRed:0 green:(188.0/255.0) blue:(212.0/255.0) alpha:1.0]];
    
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
