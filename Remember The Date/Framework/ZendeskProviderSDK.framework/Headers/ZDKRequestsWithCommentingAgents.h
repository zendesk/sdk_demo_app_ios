//
//  ZDKRequestsWithCommentingAgents.h
//  ZendeskProviderSDK
//
//  Created by Ronan Mchugh on 15/12/2017.
//  Copyright © 2017 Zendesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZDKUser, ZDKRequest;

@interface ZDKRequestsWithCommentingAgents : NSObject

@property (nonatomic, strong) NSArray<ZDKRequest *> *requests;
@property (nonatomic, strong) NSArray<ZDKUser *> *commentingAgents;


- (instancetype)initWithRequests:(NSArray <ZDKRequest*>*)requests andCommentingAgents:(NSArray <ZDKUser*>*)commentingAgents;

@end
