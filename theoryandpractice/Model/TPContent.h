//
//  TPContent.h
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface TPContent : NSManagedObject

@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *comments;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *descriptionNews;
@property (nonatomic, retain) NSNumber *favorit;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, retain) NSNumber *isRead;
@property (nonatomic, retain) NSString *newsURL;
@property (nonatomic, retain) NSDate   *pubDate;
@property (nonatomic, retain) NSString *titleNews;
@property (nonatomic, retain) NSNumber *badgeOn;
@property (nonatomic, retain) NSNumber *isFull;
@property (nonatomic, retain) NSString *imageURL;


@end
