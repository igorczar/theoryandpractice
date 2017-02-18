//
//  TPFeedCollectionViewCell.m
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import "TPFeedCollectionViewCell.h"
#import <NSString+HTML.h>
#import <SDWebImage+ExtensionSupport/UIImageView+WebCache.h>

@implementation TPFeedCollectionViewCell

-(void)configureCell:(TPContent *)item{
    
    self.newsTitle.text = item.titleNews;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm   dd.MM.YYYY"];
    self.timeLabel.text = [NSString stringWithFormat:@"%@",[ formatter stringFromDate:item.pubDate]];
    
    NSString *description = [item.descriptionNews stringByDecodingHTMLEntities];
    
    self.newsDescription.text = description;
    
    NSURL *imageURL = [NSURL URLWithString:item.imageURL];
    [self.newsImage sd_setImageWithURL:imageURL placeholderImage:[UIImage new]];
    //UIColor *backgroundColor = nil;
    
//    if (item.isRead.boolValue) {
//        backgroundColor = [UIColor colorWithRed:0.98 green:0.97 blue:0.96 alpha:1.0];
//    } else {
//        backgroundColor = [UIColor colorWithRed:0.94 green:0.93 blue:0.92 alpha:1.0];
//    }
//    self.backgroundColor = backgroundColor;
}


@end
