//
//  TPWebViewController.h
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPAPIArticlesClient.h"
#import "TPContent.h"

@interface TPWebViewController : UIViewController<UIWebViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;


@property (strong, nonatomic) NSString* body;
@property (strong, nonatomic) NSString* header;
@property (strong, nonatomic) NSString* link;

@end
