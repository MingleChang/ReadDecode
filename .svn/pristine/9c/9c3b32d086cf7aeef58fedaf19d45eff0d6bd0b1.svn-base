//
//  WebDownLoadViewController.m
//  BaiduWeb
//
//  Created by admin001 on 14-9-29.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import "WebDownLoadViewController.h"

#define OPEN_URL_CONTAIN @"baidupcs.com"

@interface WebDownLoadViewController ()
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)UIViewController *myRootViewcontroller;
-(void)setupView;
-(void)setupNaviagtionBar;
-(void)leftBarButtonClick:(UIBarButtonItem *)sender;
@end

@implementation WebDownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setupView{
    self.myRootViewcontroller=[[UIViewController alloc]init];
    //    [self pushViewController:lViewController animated:NO];
    self.viewControllers=@[self.myRootViewcontroller];
    [self setupNaviagtionBar];
    
    self.webView=[[UIWebView alloc]initWithFrame:self.myRootViewcontroller.view.bounds];
    self.webView.delegate=self;
    [self.myRootViewcontroller.view addSubview:self.webView];
    
    NSString *lURLString=self.urlString;
    NSURL *lURL=[NSURL URLWithString:lURLString];
    NSURLRequest *lRequest=[NSURLRequest requestWithURL:lURL];
    [self.webView loadRequest:lRequest];
}
-(void)setupNaviagtionBar{
    self.myRootViewcontroller.title=@"选择分享文件";
    UIBarButtonItem *lLeftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonClick:)];
    self.myRootViewcontroller.navigationItem.leftBarButtonItem=lLeftBarButtonItem;
}
-(void)leftBarButtonClick:(UIBarButtonItem *)sender{
    if ([self.webDownLoadDelegate respondsToSelector:@selector(webDownLoadViewControllerDidCancel:)]) {
        [self.webDownLoadDelegate webDownLoadViewControllerDidCancel:self];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(NSString *)getFileName{
    NSString *lString=[self.webView stringByEvaluatingJavaScriptFromString:@"getFileName();"];
    return lString;
}
#pragma mark - WebView Delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.absoluteString rangeOfString:OPEN_URL_CONTAIN].location!=NSNotFound) {
        if ([self.webDownLoadDelegate respondsToSelector:@selector(webDownLoadViewController:selectedShareURL: andFileName:)]) {
            [self.webDownLoadDelegate webDownLoadViewController:self selectedShareURL:request.URL.absoluteString andFileName:[self getFileName]];
        }
        [self dismissViewControllerAnimated:NO completion:nil];
        return NO;
    }
    return YES;
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *lString=[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Test" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    [self.webView stringByEvaluatingJavaScriptFromString:lString];
    [self.webView stringByEvaluatingJavaScriptFromString:@"downLoadFile();"];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}
@end
