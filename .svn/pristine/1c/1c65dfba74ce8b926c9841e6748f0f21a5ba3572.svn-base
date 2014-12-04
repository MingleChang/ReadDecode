//
//  BaiduWebViewController.m
//  BaiduWeb
//
//  Created by admin001 on 14-9-28.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import "BaiduWebViewController.h"

#define SELECTED_FILE_URL @"http://pan.baidu.com/wap/link"
#define SHARE_URL @"http://pan.baidu.com/wap/share/home"
#define FILENAME_KEY @"fileName"
#define FILEPATH_KEY @"filePath"

@interface BaiduWebViewController ()
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)UIViewController *myRootViewcontroller;

@property(nonatomic,copy)NSArray *shareFile;
@end

@implementation BaiduWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    
    NSString *lURLString=SHARE_URL;
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
    if ([self.baiduWebDelegate respondsToSelector:@selector(baiduWebViewControllerDidCancel:)]) {
        [self.baiduWebDelegate baiduWebViewControllerDidCancel:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)getAllFileNameAndPath{
    NSString *lString=[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Test" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    lString=[lString stringByAppendingString:@"getAllFileNameAndPath();"];
    lString=[self.webView stringByEvaluatingJavaScriptFromString:lString];
    self.shareFile=[NSJSONSerialization JSONObjectWithData:[lString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@",self.shareFile);
}
-(NSString *)getFileNameWithFilePath:(NSString *)filePath{
    if (self.shareFile==nil||self.shareFile.count==0) {
        return nil;
    }
    for (NSDictionary *lDic in self.shareFile) {
        NSString *lFileName=[lDic objectForKey:FILENAME_KEY];
        NSString *lFilePath=[lDic objectForKey:FILEPATH_KEY];
        if ([lFilePath isEqualToString:filePath]) {
            return lFileName;
        }
    }
    return nil;
}
#pragma mark - WebView Delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.absoluteString rangeOfString:SELECTED_FILE_URL].location!=NSNotFound) {
        [self getAllFileNameAndPath];
        if ([self.baiduWebDelegate respondsToSelector:@selector(baiduWebViewController:selectedShareURL: andFileName:)]) {
            [self.baiduWebDelegate baiduWebViewController:self selectedShareURL:request.URL.absoluteString andFileName:[self getFileNameWithFilePath:request.URL.absoluteString]];
        }
        [self dismissViewControllerAnimated:NO completion:nil];
        return NO;
    }
    return YES;
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}
@end
