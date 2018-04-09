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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UITextField *dateText;

@end

@implementation NewDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDate *now = [NSDate date];
    self.datePicker.minimumDate = now;
    [self.dateNameTextField setTintColor:[[UIColor alloc] initWithRed:0 green:(188.0/255.0) blue:(212.0/255.0) alpha:1.0]];
    // Do any additional setup after loading the view.
    if (self.notification == nil) {
        [self.deleteButton setTintColor:[UIColor clearColor]];
        [self.deleteButton setEnabled:NO];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, dd MMM, HH:mm"];
    [self.dateText setText:[formatter stringFromDate: self.datePicker.date]];
    [self.dateText setEnabled:NO];
    
}
- (IBAction)setDate:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, dd MMM, HH:mm"];
    
    [self.dateText setText:[formatter stringFromDate: self.datePicker.date]];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.notification != nil)
    {
        self.datePicker.date        = self.notification.fireDate;
        self.dateNameTextField.text = self.notification.alertBody;
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
- (IBAction)deleteTapped:(id)sender {
        [[UIApplication sharedApplication] cancelLocalNotification:self.notification];
        [self dismissViewControllerAnimated:YES completion:^{}];
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
