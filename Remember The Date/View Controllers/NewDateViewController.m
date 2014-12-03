//
//  NewDateViewController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import "NewDateViewController.h"

#define MINUTE  60
#define HOUR    60*MINUTE
#define DAY     HOUR*24

@interface NewDateViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *dateNameTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation NewDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datePicker.minimumDate = [NSDate date];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.notification != nil)
    {
        self.datePicker.date        = self.notification.fireDate;
        self.dateNameTextField.text = self.notification.alertBody;
        
        self.navigationItem.rightBarButtonItem.title    = NSLocalizedString(@"Save", @"");
    }
    else
    {
        self.datePicker.date        = [NSDate dateWithTimeIntervalSinceNow:DAY];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.dateNameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAddTapped:(id)sender {
    if ([self.dateNameTextField.text isEqualToString:@""] == NO)
    {
        BOOL isAfter = [self.datePicker.date compare:[NSDate date]] == NSOrderedDescending;
        
        if (isAfter)
        {
            if (self.notification != nil)
            {
                [[UIApplication sharedApplication] cancelLocalNotification:self.notification];
            }
            
            UILocalNotification *notification   = [[UILocalNotification alloc] init];
            notification.fireDate               = self.datePicker.date;
            notification.timeZone               = [NSTimeZone localTimeZone];
            notification.alertBody              = self.dateNameTextField.text;
            notification.soundName              = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            });
        }
        else
        {
            // Tell the user
            UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"The date/time should be after, well, now.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            
            [alert show];
        }
    }
    else
    {
        // Tell the user
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"You must fill a Title", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        
        [alert show];

    }
    
}

- (IBAction)onCancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];   
}


@end
