/*
 *
 *  ZDKRequests.h
 *  ZendeskSDK
 *
 *  Created by Zendesk on 22/04/2014.  
 *
 *  Copyright (c) 2014 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Terms
 *  of Service https://www.zendesk.com/company/terms and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/application-developer-and-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */


#import <Foundation/Foundation.h>
#import "ZDKAPIDispatcher.h"
#import "ZDKCreateRequestViewController.h"
#import "ZDKRequestListTableCell.h"
#import "ZDKRequestListTable.h"
#import "ZDKRequestCommentsViewController.h"
#import "ZDKRequestCommentsView.h"
#import "ZDKRequestCommentsTable.h"
#import "ZDKCommentEntryView.h"
#import "ZDKRequestCommentTableCell.h"
#import "ZDKCreateRequestUIDelegate.h"

#pragma mark Request creation config


/**
 * Request creation config object.
 */
@interface ZDKRequestCreationConfig : NSObject {

    NSArray *tags;
    NSString *additionalRequestInfo;

}


/**
 * Tags to be included when creating a request.
 */
@property (strong) NSArray *tags;


/**
 * Additional free text to be appended to the request description.
 */
@property (strong) NSString *additionalRequestInfo;


/**
 * Helper method providing a simple visual separator for request info including line breaks.
 * @return @"\n\n";
 */
- (NSString*) contentSeperator;


@end


#pragma mark - ZDKRequests


/**
 * Config block.
 * @param account the account on which the subdomain and user can be set
 * @param requestCreationConfig the Request creation config which can be updated as desired.
 */
typedef void (^ZDSDKConfigBlock) (ZDKAccount *account, ZDKRequestCreationConfig *requestCreationConfig);


/**
 * Core SDK class providing access to request deflection, creation and lists.
 */
@interface ZDKRequests : NSObject  <ZDKCreateRequestUIDelegate> {

    ZDKRequestCreationConfig *requestCreationConfig;

}


/**
 * Request creation config for this instance.
 */
@property (strong) ZDKRequestCreationConfig *requestCreationConfig;


/**
 * Get the instance of ZDKRequests
 * @return ZDKRequests A shared instance of ZDKRequests
 */
+ (instancetype) instance;


/**
 * Configure the SDK
 * @param config the config block with which to setup the SDK.
 */
+ (void) configure:(ZDSDKConfigBlock)config;


/**
 *  Displays a simple request creation modal. The modal is presented on top the view controller
 *  that is passed in.
 *
 *  @param navController The UINavigationController from which to pressent the request creation view.
 */
+ (void) showRequestCreationWithNavController:(UINavigationController*)navController;


/**
 *  Displays a simple request creation modal. The modal is presented on top the view controller
 *  that is passed in.
 *
 *  @param navController The UINavigationController from which to pressent the request creation view.
 *  @param success       A block that is executed on successfull submission of a request.
 *  @param error         A block that is executed when an error occurs during submission of a request.
 */
+ (void) showRequestCreationWithNavController:(UINavigationController*)navController
                                  withSuccess:(ZDKAPISuccess)success
                                     andError:(ZDKAPIError)error;


/**
 *  Displays a request list view controller.
 *
 *  @param navController A navigation controller from which to push the request creation view.
 */
+ (void) showRequestListWithNavController:(UINavigationController *)navController;


/**
 * Create a new request list component for use, initially the component will have a CGRectZero frame.
 *
 * @param observer event observer for receiving notification of table updates
 * @param selector the selector to be invoked on table update events
 * @return a new request list component
 */
+ (ZDKRequestListTable*) newRequestListWith:(id)observer andSelector:(SEL)selector;


/**
 *  Specify an icon that will be placed in the right nav bar button.
 *
 *  @param name The name of an image in your app bundle.
 */
+ (void) setNewRequestBarButtonImage:(NSString *)name;


/**
 *  Set the nav bar UI type for displaying the create request screen.
 *
 *  @param uiType A ZDKNavBarCreateRequestUIType.
 */
+ (void) setNavBarCreateRequestUIType:(ZDKNavBarCreateRequestUIType)uiType;


@end
