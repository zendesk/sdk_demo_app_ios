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
