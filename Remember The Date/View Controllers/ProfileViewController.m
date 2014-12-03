//
//  ProfileViewController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
    
    if ([defaults stringForKey:@"userName"] != nil)
    {
        self.nameLabel.text         = [defaults stringForKey:@"userName"];
        self.emailLabel.text        = [defaults stringForKey:@"email"];
        
        // Photo
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
        UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
        
        self.userImageView.image    = img;
    }
    
    self.userImageView.layer.cornerRadius   = CGRectGetWidth(self.userImageView.frame)/2;
    self.userImageView.layer.masksToBounds  = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTappedSignOutButton:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)onEditTapped:(id)sender {
    UINavigationController  *editController = [self.storyboard instantiateViewControllerWithIdentifier:@"createProfile"];
    [self presentViewController:editController animated:YES completion:^{
        
    }];
}

- (IBAction)onCloseTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
