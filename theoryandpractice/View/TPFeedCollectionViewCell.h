//
//  TPFeedCollectionViewCell.h
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPContent.h"

@interface TPFeedCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UILabel *newsDescription;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet UILabel *favoriteLabel;

- (void)configureCell:(TPContent *)item;

@end
