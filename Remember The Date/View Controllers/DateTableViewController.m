//
//  DateTableViewController.m
//  Remember The Date
//
//  Created by Zendesk on 10/10/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import "DateTableViewController.h"
#import "NewDateViewController.h"

@interface DateTableViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong)   NSArray     *notificationsArray;
@property (nonatomic, strong)   NSDateFormatter *formatter;
@property (nonatomic, strong)   NSIndexPath *indexPathToBeDeleted;
@property (nonatomic, strong)   UIView  *emptyView;
@end

@implementation DateTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.formatter  = [[NSDateFormatter alloc] init];
    [self.formatter setTimeStyle:NSDateFormatterNoStyle];
    [self.formatter setDateStyle:NSDateFormatterShortStyle];
    [self.formatter setDateFormat:@"EEE, dd MMM, HH:mm"];
    
    self.emptyView  = [[[NSBundle mainBundle] loadNibNamed:@"EmptyView" owner:nil options:nil] firstObject];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor  = [UIColor colorWithRed:(250.0/255.0) green:(250.0/255.0) blue:(250.0/255.0) alpha:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadTableView];
    if ([self.notificationsArray count] == 0)
    {
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.emptyView.frame    = self.view.frame;
        self.emptyView.center = self.view.center;
        self.edgesForExtendedLayout = UIRectEdgeBottom;
        [self.view bringSubviewToFront:self.emptyView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onProfileTapped:(id)sender {
    UINavigationController  *destinationController  = nil;
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"userName"] != nil)
    {
        destinationController   = [self.storyboard instantiateViewControllerWithIdentifier:@"viewProfile"];
    }
    else
    {
        destinationController   = [self.storyboard instantiateViewControllerWithIdentifier:@"createProfile"];
    }
    
    [self presentViewController:destinationController animated:YES completion:^{
        
    }];
}

#pragma mark - UITableView

- (void)reloadTableView
{
    UIApplication   *application    = [UIApplication sharedApplication];
    self.notificationsArray = [application scheduledLocalNotifications];
    [self.tableView reloadData];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:@"DateCell" forIndexPath:indexPath];
    
    UILabel *dateName       = (UILabel *)[cell viewWithTag:1001];
    UILabel *date           = (UILabel *)[cell viewWithTag:1002];
    
    UILocalNotification *currentNotification    = [self.notificationsArray objectAtIndex:indexPath.row];
    
    dateName.text           = currentNotification.alertBody;
    date.text               = [self.formatter stringFromDate:currentNotification.fireDate];
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger   number  = [self.notificationsArray count];
    if (number > 0)
    {
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [self.emptyView removeFromSuperview];
    }
    else
    {
        if ([self.emptyView superview] == nil)
        {
            [self.view addSubview:self.emptyView];
            [self.emptyView setFrame:CGRectMake(0, 0, self.emptyView.frame.size.height, self.emptyView.frame.size.width)];
        }
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    
    return number;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UINavigationController  *addController  = [self.storyboard instantiateViewControllerWithIdentifier:@"newDate"];
    NewDateViewController   *newDateVC      = [[addController childViewControllers] firstObject];
    
    newDateVC.notification                  = [self.notificationsArray objectAtIndex:indexPath.row];
    
    [self presentViewController:addController animated:YES completion:^{
        
    }];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"OK", @"")])
    {
        UILocalNotification *notification   = [self.notificationsArray objectAtIndex:self.indexPathToBeDeleted.row];
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadTableView];            
        });
        
        self.indexPathToBeDeleted   = nil;
    }
}

@end
