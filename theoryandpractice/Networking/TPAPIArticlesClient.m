//
//  TPAPIArticlesClient.m
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import "TPAPIArticlesClient.h"
#import <AFNetworking/AFNetworking.h>
#import "TPCoreDataStack.h"
#import <MWFeedItem.h>

@interface TPAPIArticlesClient ()

@property (nonatomic, getter = isUpdating) BOOL updating;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) MWFeedParser *feedParser;

@property (copy, nonatomic) void (^completion) (BOOL updated, NSUInteger newItem);

@property (assign, nonatomic) NSUInteger newItem;

@end

double const PMTreeWeeksTimeInterval = 1814400;

@implementation TPAPIArticlesClient

+ (instancetype)sharedClient
{
    static id __sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *feedURL = [NSURL URLWithString:@"http://theoryandpractice.ru/rss/posts"];
        __sharedClient = [[[self class] alloc] initWithFeedURL:feedURL];
    });
    return __sharedClient;
}

- (instancetype)initWithFeedURL:(NSURL *)feedURL
{
    self = [super init];
    if (self) {
        MWFeedParser *feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
        feedParser.delegate = self;
        feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
        feedParser.connectionType = ConnectionTypeAsynchronously;
        self.feedParser = feedParser;
        self.managedObjectContext = [TPCoreDataStack defaultDataSource].managedObjectContext;
    }
    return self;
}


#pragma mark - Public methods

- (void)updateArticlesWithCompletionHandler:(void (^)(BOOL updated, NSUInteger newItem))completion
{
    if (self.isUpdating) {
        if (self.completion) {
            self.completion(NO, 0);
        }
    } else {
        self.updating = YES;
        self.completion = completion;
        self.newItem = 0;
        [self.feedParser parse];
    }
}

#pragma mark - MWFeedParserDelegate

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item
{
    NSDate* now = [[NSDate alloc] init];
    double diff = [now timeIntervalSince1970] - [item.date timeIntervalSince1970];
    if (diff < PMTreeWeeksTimeInterval ) {
        [self parseFeedItem:item];
    }
}

- (void)parseFeedItem:(MWFeedItem *)item
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Content"];
    request.predicate = [NSPredicate predicateWithFormat:@"newsURL = %@", item.link];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        return;
    }
    
    TPContent *content = result.firstObject;
    if (!content || !content.isFull) {
        content = [NSEntityDescription insertNewObjectForEntityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
        NSString *title = [item.title stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
        content.titleNews       = title;
        content.pubDate         = item.date;
        content.newsURL         = item.link;
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:item.link parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *draftContent = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<meta content=\".*?\" property=\"og:image\" />"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:nil];
            
            NSArray *matches = [regex matchesInString:draftContent options:0 range:NSMakeRange(0, [draftContent length])];
            for (NSTextCheckingResult *match in matches) {
                NSRange matchRange = [match range];
                NSString *imageURL = [draftContent substringWithRange:matchRange];
                imageURL = [imageURL stringByReplacingOccurrencesOfString:@"<meta content=\"" withString:@""];
                imageURL = [imageURL stringByReplacingOccurrencesOfString:@"\" property=\"og:image" withString:@""];
                imageURL = [imageURL stringByReplacingOccurrencesOfString:@"\" />" withString:@""];
                
                content.imageURL = imageURL;
            }
            
            NSRegularExpression *regexDescription = [NSRegularExpression regularExpressionWithPattern:@"<meta content=\".*?\" property=\"og:description\" />"
                                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                                error:nil];
            
            NSArray *descriptionsMatches = [regexDescription matchesInString:draftContent options:0 range:NSMakeRange(0, [draftContent length])];
            for (NSTextCheckingResult *match in descriptionsMatches) {
                NSRange matchRange = [match range];
                NSString *description = [draftContent substringWithRange:matchRange];
                description = [description stringByReplacingOccurrencesOfString:@"<meta content=\"" withString:@""];
                description = [description stringByReplacingOccurrencesOfString:@"\" property=\"og:description" withString:@""];
                description = [description stringByReplacingOccurrencesOfString:@"\" />" withString:@""];
                
                content.descriptionNews = description;
            }
            
            
            NSRange range = [draftContent rangeOfString:@"<div class=\"seedr_banner_wrapper\">"];
            NSRange range2 = [draftContent rangeOfString:@"<div class=\"articleBody\" itemprop=\"articleBody\">"];
            
            range2 = range2.location != NSNotFound ? range2 : [draftContent rangeOfString:@"<div class=\"articleBody fm-post-body\" itemprop=\"articleBody\">"];
            
            NSRange guideRange = [draftContent rangeOfString:@"<div class=\"guidetext\">"];
            
            if (guideRange.location != NSNotFound) {
                NSString* guideText = [draftContent substringFromIndex:guideRange.location+23];
                
                
                
                NSRange guideEnd = [guideText rangeOfString:@"</div>"];
                
                if (guideEnd.location != NSNotFound) {
                    guideText = [guideText substringToIndex:guideEnd.location];
                    
                    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                    
                    [defaults setValue:guideText forKey:@"guideText"];
                    [defaults synchronize];
                }
                
            }
            
            
            if (range.location != NSNotFound && range2.location != NSNotFound) {
                draftContent = [draftContent substringToIndex:range.location];
                draftContent = [draftContent substringFromIndex:range2.location];
                content.content = [draftContent stringByReplacingOccurrencesOfString:@"//www.youtube" withString:@"http://www.youtube"];
                content.isFull = @YES;
            }
            else {
                [self.managedObjectContext deleteObject:content];
                content.content = @"";
            }
            [self.managedObjectContext save:nil];

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        self.newItem++;
    }
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error
{
    self.updating = NO;
    
    if (self.completion) {
        self.completion(NO, 0);
        self.completion = nil;
    }
}

- (void)feedParserDidFinish:(MWFeedParser *)parser
{
    [self.managedObjectContext save:nil];
    
    [[TPCoreDataStack defaultDataSource] updateBadgeNumber];
    self.updating = NO;
    
    if (self.completion) {
        self.completion(YES, self.newItem);
        self.completion = nil;
    }
}

- (void)saveContext
{
    NSError* error;
    [self.managedObjectContext save:&error];
}


@end
