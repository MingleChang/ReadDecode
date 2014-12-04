//
//  BaiduWebViewController.h
//  BaiduWeb
//
//  Created by admin001 on 14-9-28.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BaiduWebViewControllerDelegate;
@interface BaiduWebViewController : UINavigationController<UIWebViewDelegate>
@property(nonatomic,strong)id<BaiduWebViewControllerDelegate> baiduWebDelegate;
@end
@protocol BaiduWebViewControllerDelegate <NSObject>

-(void)baiduWebViewController:(BaiduWebViewController *)baiduWebViewController selectedShareURL:(NSString *)urlString andFileName:(NSString *)fileName;
-(void)baiduWebViewControllerDidCancel:(BaiduWebViewController *)baiduWebViewController;

@end