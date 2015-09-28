//
//  CreateProfileTableViewController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import <ZendeskSDK/ZendeskSDK.h>
#import "CreateProfileTableViewController.h"

extern NSString *APNS_ID_KEY;

@interface CreateProfileTableViewController ()<UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation CreateProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
    
    if ([defaults stringForKey:@"userName"] != nil)
    {
        // We have a profile!
        
        self.nameTextField.text         = [defaults stringForKey:@"userName"];
        self.emailTextField.text        = [defaults stringForKey:@"email"];
        self.passwordTextField.text     = [defaults stringForKey:@"password"];
        
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Save", @"")];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
        UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
        
        if (img != nil)
            [self.pictureButton setImage:img forState:UIControlStateNormal];
    }
    
    
    self.pictureButton.layer.cornerRadius   = CGRectGetWidth(self.pictureButton.frame)/2;
    self.pictureButton.layer.masksToBounds  = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPictureButtonTapped:(id)sender {
    UIActionSheet   *actionSheet    = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select a photo source", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", @"")];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Photo Library", @"")];
    [actionSheet showInView:self.view];

}

- (IBAction)onCreateTapped:(id)sender {
    if ([self.nameTextField.text isEqualToString:@""] == NO)
    {
        NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.nameTextField.text forKey:@"userName"];
        [defaults setObject:self.emailTextField.text forKey:@"email"];
        [defaults setObject:self.passwordTextField.text forKey:@"password"];
        [defaults synchronize];
        
        [ZDKConfig instance].userIdentity = [[ZDKJwtIdentity alloc]
                                             initWithJwtUserIdentifier:self.emailTextField.text];
        
        NSString *pushIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:APNS_ID_KEY];
        
        //Push is en
        if(pushIdentifier) {
            [[ZDKConfig instance] enablePushWithDeviceID:pushIdentifier callback:^(ZDKPushRegistrationResponse *registrationResponse, NSError *error) {
                
                if (error) {
                    
                    NSLog(@"Couldn't register device: %@. Error: %@ in %@", pushIdentifier, error, self.class);
                    
                } else if (registrationResponse) {
                    
                    NSLog(@"Successfully registered device: %@ in %@", pushIdentifier, self.class);
                }
            }];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else
    {
        // Alert user
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please fill out all fields.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        
        [alert show];
    }
}

- (IBAction)onCloseTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
    
    // And dismiss
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
