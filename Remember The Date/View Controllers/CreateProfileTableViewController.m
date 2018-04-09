//
//  CreateProfileTableViewController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import <ZendeskSDK/ZendeskSDK.h>
#import <ZendeskCoreSDK/ZendeskCoreSDK-Swift.h>
#import "CreateProfileTableViewController.h"

extern NSString *APNS_ID_KEY;

@interface CreateProfileTableViewController ()<UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *profileCell;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) BOOL isSignedIn;
@end

@implementation CreateProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
    [self.nameTextField setEnabled:NO];
    [self.emailTextField setEnabled:NO];
    
    self.isSignedIn = YES;
    
    if ([defaults stringForKey:@"userName"] != nil)
    {
        // We have a profile!
        self.nameTextField.text         = [defaults stringForKey:@"userName"];
        self.emailTextField.text        = [defaults stringForKey:@"email"];
        [self.nameTextField setTintColor:[[UIColor alloc] initWithRed:0 green:(188.0/255.0) blue:(212.0/255.0) alpha:1.0]];
        [self.emailTextField setTintColor:[[UIColor alloc] initWithRed:0 green:(188.0/255.0) blue:(212.0/255.0) alpha:1.0]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
        UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
        
        if (img != nil) {
            [self.pictureButton setImage:img forState:UIControlStateNormal];
            self.pictureButton.layer.cornerRadius   = CGRectGetWidth(self.pictureButton.frame)/2;
            self.pictureButton.layer.masksToBounds  = YES;
        }

    }
    
}
- (IBAction)editButtonTapped:(id)sender {
    
    if (self.isSignedIn) {
        [self.nameTextField setEnabled:YES];
        [self.emailTextField setEnabled:YES];
        [self.barButton setTitle:@"Done"];
        [self.barButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]} forState:UIControlStateNormal];
        if (self.nameTextField.text == nil || [self.nameTextField.text isEqualToString: @""]) {
            [self.nameTextField becomeFirstResponder];
        } else if ([self.nameTextField hasText] && [self.emailTextField hasText]) {
            [self.nameTextField becomeFirstResponder];
        } else {
            [self.emailTextField becomeFirstResponder];
        }
        self.isSignedIn = NO;
    } else {
        NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.nameTextField.text forKey:@"userName"];
        [defaults setObject:self.emailTextField.text forKey:@"email"];
        [defaults synchronize];
        
        id<ZDKObjCIdentity> userIdentity = [[ZDKObjCJwt alloc] initWithToken:self.emailTextField.text];
        [[ZDKZendesk instance] setIdentity:userIdentity];
        
        NSString *pushIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:APNS_ID_KEY];
        
        //Push is en
        if(pushIdentifier) {
            NSString * locale = [[NSLocale preferredLanguages] firstObject];
            
            [[[ZDKPushProvider alloc] initWithZendesk:[ZDKZendesk instance]] registerWithDeviceIdentifier:pushIdentifier locale:locale completion:^(NSString * _Nullable registrationResponse, NSError * _Nullable error) {
                if (error) {
                    
                    NSLog(@"Couldn't register device: %@. Error: %@ in %@", pushIdentifier, error, self.class);
                    
                } else if (registrationResponse) {
                    
                    NSLog(@"Successfully registered device: %@ in %@", pushIdentifier, self.class);
                }
            }];
            
        }
        self.isSignedIn = YES;
        [self.nameTextField setEnabled:NO];
        [self.emailTextField setEnabled:NO];
        [self.barButton setTitle:@"Edit"];
        [self.barButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightRegular]} forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPictureButtonTapped:(id)sender {
    [self.nameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    UIActionSheet   *actionSheet    = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select a photo source", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", @"")];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Photo Library", @"")];
    [actionSheet showInView:self.view];

}

#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"])
    {
        // Camera
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate         = self;
        picker.allowsEditing    = YES;
        picker.sourceType       = UIImagePickerControllerSourceTypeCamera;
        
        //iOS 8 workaround for compability with iPad
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self presentViewController:picker animated:YES completion:^{
                    
                }];
            }];
        }
        else
        {
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }

    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Photo Library", @"")])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate         = self;
        picker.allowsEditing    = YES;
        picker.sourceType       = UIImagePickerControllerSourceTypePhotoLibrary;
        
        //iOS 8 workaround for compability with iPad
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self presentViewController:picker animated:YES completion:^{
                    
                }];
            }];
        }
        else
        {
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }

    }
}

#pragma mark - ImagePicker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.pictureButton setImage:img forState:UIControlStateNormal];
    
    // Let's save the file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
    NSData *imageData = UIImagePNGRepresentation(img);
    [imageData writeToFile:savedImagePath atomically:NO];
    self.pictureButton.layer.cornerRadius   = CGRectGetWidth(self.pictureButton.frame)/2;
    self.pictureButton.layer.masksToBounds  = YES;
    
    // And dismiss
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
