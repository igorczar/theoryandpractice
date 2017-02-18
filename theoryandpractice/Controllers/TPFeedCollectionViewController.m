//
//  TPFeedCollectionViewController.m
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import "TPFeedCollectionViewController.h"
#import "TPCoreDataStack.h"
#import "TPAPIArticlesClient.h"
#import "TPFeedCollectionViewCell.h"
#import "TPWebViewController.h"

@interface TPFeedCollectionViewController ()<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TPFeedCollectionViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    NSManagedObjectContext *context = [TPCoreDataStack defaultDataSource].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Content"];
    request.sortDescriptors = @[ [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO] ];
    request.fetchBatchSize = 50;
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    [self.fetchedResultsController performFetch:nil];
    
    
    [[TPAPIArticlesClient sharedClient] updateArticlesWithCompletionHandler:nil];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:NULL];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_icon"]];
    self.navigationItem.titleView = logoView;
    /*
     self.refreshHeader = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
     
     
     self.refreshHeader.lastUpdatedTimeLabel.hidden = YES;
     self.refreshHeader.stateLabel.hidden = YES;
     
     self.collectionView.mj_header = self.refreshHeader;
     */
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    
//    [self.collectionView.refreshControl addTarget:self
//                                           action:@selector(loadNewData)
//                                 forControlEvents:UIControlEventValueChanged];
    
    self.collectionView.refreshControl = refreshControl;
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.collectionView.refreshControl endRefreshing];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.collectionView reloadData];
    
    NSString* guideText = [[NSUserDefaults standardUserDefaults] stringForKey:@"guideText"];
    
    if (guideText) {
        self.collectionView.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:guideText];
    }
    
}

//-(void) loadNewData
//{
//    
//    NSString* guideText = [[NSUserDefaults standardUserDefaults] stringForKey:@"guideText"];
//    
//    if (guideText) {
//        
//        [self.refreshHeader setTitle:guideText forState:MJRefreshStateRefreshing];
//    }
//    
//    [self.refreshHeader beginRefreshing];
//    [self.collectionView reloadData];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.refreshHeader endRefreshing];
//    });
//}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) selectedFovorit:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 1) {
        self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"favorit = YES" ];
    } else {
        self.fetchedResultsController.fetchRequest.predicate = nil;
    }
    [self.fetchedResultsController performFetch:nil];
    [self.collectionView reloadData];
}

//-(void)prepereSetting:(UIStoryboardSegue *)segue{
//    if ([segue.identifier isEqualToString:@"settings"]) {
//        SettingsViewController *settingsController = segue.destinationViewController;
//        settingsController.fetchedResultsController = self.fetchedResultsController;
//    }
//}
- (void)refresh:(UIRefreshControl *)refreshControl
{
    [[TPAPIArticlesClient sharedClient] updateArticlesWithCompletionHandler:^(BOOL updated,NSUInteger newItem) {
        [refreshControl endRefreshing];
    }];
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TPFeedCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
    TPContent *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell configureCell:item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TPContent *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGSize textSize = { self.collectionView.bounds.size.width - 30, CGFLOAT_MAX };
    UIFont *topFont = [UIFont systemFontOfSize:18];
    CGRect topFrame = [item.titleNews boundingRectWithSize:textSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName: topFont }
                                                   context:nil];
    
    UIFont *descriptionFont = [UIFont systemFontOfSize:15];
    CGRect descriptionFrame = [item.descriptionNews boundingRectWithSize:textSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName: descriptionFont }
                                                   context:nil];
    CGFloat height = 20 + topFrame.size.height + descriptionFrame.size.height + (collectionView.frame.size.width * 0.75);
    return CGSizeMake(collectionView.frame.size.width, height);
}


#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TPWebViewController *contentDetail = [[TPWebViewController alloc] initWithNibName:@"TPWebViewController" bundle:nil];
    TPContent* content = [self.fetchedResultsController objectAtIndexPath:indexPath];
    content.isRead = @YES;
    
    
    contentDetail.hidesBottomBarWhenPushed = YES;
    contentDetail.body = content.content;
    contentDetail.header = content.titleNews;
    contentDetail.link = content.newsURL;
    
    [content.managedObjectContext save:nil];
    
    [[TPCoreDataStack defaultDataSource] updateBadgeNumber ];
    
    
    [self.navigationController pushViewController:contentDetail animated:YES];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}


@end
