//
//  TPContent+CustomAccessors.m
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import "TPContent+CustomAccessors.h"

@implementation TPContent (CustomAccessors)

- (NSString *)pubDay
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterFullStyle];
    formatter.doesRelativeDateFormatting = YES;
    NSDate*pubDate = self.pubDate;
    
    NSString *pubDay = [formatter stringFromDate:pubDate];
    
    return pubDay;
}


@end
