//
//  WebDownLoadViewController.h
//  BaiduWeb
//
//  Created by admin001 on 14-9-29.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WebDownLoadViewControllerDelegate;
@interface WebDownLoadViewController : UINavigationController<UIWebViewDelegate>
@property(nonatomic,assign)id<WebDownLoadViewControllerDelegate> webDownLoadDelegate;
@property(nonatomic,copy)NSString *urlString;
@end

@protocol WebDownLoadViewControllerDelegate <NSObject>

-(void)webDownLoadViewController:(WebDownLoadViewController *)webDownLoadViewController selectedShareURL:(NSString *)urlString andFileName:(NSString *)fileName;
-(void)webDownLoadViewControllerDidCancel:(WebDownLoadViewController *)webDownLoadViewController;

@end