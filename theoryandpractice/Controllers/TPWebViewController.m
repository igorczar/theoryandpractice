//
//  TPWebViewController.m
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import "TPWebViewController.h"
#import "TPCoreDataStack.h"
#import <SafariServices/SafariServices.h>

@interface TPWebViewController ()<SFSafariViewControllerDelegate>

@property (nonatomic, strong)  NSMutableString *allContent;
@property (nonatomic) CGFloat lastOffsetY;

@end

@implementation TPWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_icon"]];
    self.navigationItem.titleView = logoView;
    
    NSString *allContent = [NSMutableString stringWithFormat:@"<h1>%@</h1> %@", self.header, self.body];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"reader" ofType:@"html"];
    
    NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    html = [html stringByReplacingOccurrencesOfString:@"@pm_content" withString:allContent];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:filePath]];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;

}

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        
        if ([SFSafariViewController class] != nil) {
            SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[inRequest URL]];
            sfvc.delegate = self;
            [self presentViewController:sfvc animated:YES completion:nil];
            
        } else {
            [[UIApplication sharedApplication] openURL:[inRequest URL]];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.lastOffsetY = self.webView.scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    BOOL hidden = self.webView.scrollView.contentOffset.y > self.lastOffsetY;
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
    //[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
    [self prefersStatusBarHidden];
}

@end
