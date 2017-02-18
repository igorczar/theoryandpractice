//
//  TPAPIArticlesClient.h
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MWFeedParser.h>

@interface TPAPIArticlesClient : NSObject<MWFeedParserDelegate>

+ (instancetype)sharedClient;

- (instancetype)initWithFeedURL:(NSURL *)feedURL;

- (void)updateArticlesWithCompletionHandler:(void (^)(BOOL updated,NSUInteger newItem))completion;
- (void)saveContext;


@end
