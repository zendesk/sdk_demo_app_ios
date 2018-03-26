/*
 *
 *  ZDKHelpCenterUi.h
 *  ZendeskSDK
 *
 *  Created by Zendesk on 15/03/2018.
 *
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/#master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/#application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */


@import UIKit;

#import "ZDKHelpCenterConversationsUIDelegate.h"

@class ZDKHelpCenterArticle;
@protocol ZDKUiConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface ZDKHelpCenterUi : NSObject

+ (UIViewController <ZDKHelpCenterDelegate>*) buildHelpCenterOverview;
+ (UIViewController <ZDKHelpCenterDelegate>*) buildHelpCenterOverviewWithConfigs:(NSArray<ZDKUiConfiguration> *)configs;

+ (UIViewController<ZDKHelpCenterDelegate>*) buildHelpCenterArticle:(ZDKHelpCenterArticle *)article;
+ (UIViewController<ZDKHelpCenterDelegate>*) buildHelpCenterArticle:(ZDKHelpCenterArticle *)article
                                                         andConfigs:(NSArray<ZDKUiConfiguration> *)configs;

+ (UIViewController<ZDKHelpCenterDelegate>*) buildHelpCenterArticleWithArticleId:(NSInteger)articleId;
+ (UIViewController<ZDKHelpCenterDelegate>*) buildHelpCenterArticleWithArticleId:(NSInteger)articleId
                                                                      andConfigs:(NSArray<ZDKUiConfiguration> *)configs;


@end

NS_ASSUME_NONNULL_END
