/*
 *
 *  ZDKArticleView.h
 *  ZendeskSDK
 *
 *  Created by Zendesk on 24/09/2014.  
 *
 *  Copyright (c) 2014 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Terms
 *  of Service https://www.zendesk.com/company/terms and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/application-developer-and-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import <UIKit/UIKit.h>

@class ZDKHelpCenterArticle;

@interface ZDKArticleView : UIView


/**
 * Scroll view that contains the article webview and attachments table
 */
@property (nonatomic, strong) UIScrollView *article;

/**
 * The article body.
 */
@property (nonatomic, strong) UIWebView *articleWebView;


/**
 * A table for article attachments.
 */
@property (nonatomic, strong) UITableView *attachments;



@property (nonatomic, assign, readonly, getter=isLoading) BOOL loading;


/**
 * Initializes the article controller with an article.
 *
 * @param article A help center article.
 */
- (instancetype) initWithArticle:(ZDKHelpCenterArticle *)article;


/**
 * Reloads the help center article webview on rotation.
 *
 */
- (void) reloadArticleForRotation;


@end
