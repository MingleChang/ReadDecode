//
//  ViewController.m
//  ReadDecode
//
//  Created by admin001 on 14-10-13.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import "ViewController.h"
#import "ZipArchive.h"
#import "BookManager.h"
#import "Book.h"
#import "DownLoadManager.h"
#import "DownloadViewController.h"
@interface ViewController ()
@property(nonatomic,copy)NSString *shareString;
- (IBAction)webfenxiang:(UIButton *)sender;
- (IBAction)webxiazai:(UIButton *)sender;
- (IBAction)duqushuji:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    Book *lBook=[[BookManager share]decoderBookWith:@"/Users/gaolong/Book/1111.txt"];
//    NSString *lString=[lBook getHtmlStringByChapterIndex:lBook.chapterNumber];
    
//    Book *lBook=[[BookManager share]decoderBookWith:@"/Users/gaolong/Desktop/Book/4444.ebk2"];
//    NSString *lString=[lBook getHtmlStringByChapterIndex:lBook.chapterNumber-1];
    
//    Book *lBook=[[BookManager share]decoderBookWith:@"/Users/gaolong/Desktop/Book/2222.umd"];
//    NSString *lString=[lBook getHtmlStringByChapterIndex:lBook.chapterNumber-2];
    
//    Book *lBook=[[BookManager share]decoderBookWith:@"/Users/gaolong/Desktop/Book/0000.epub"];
//    NSString *lString=[lBook getHtmlStringByChapterIndex:21];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)webfenxiang:(UIButton *)sender {
    BaiduWebViewController *lViewController=[[BaiduWebViewController alloc]init];
    lViewController.baiduWebDelegate=self;
    [self presentViewController:lViewController animated:YES completion:nil];
}

- (IBAction)webxiazai:(UIButton *)sender {
    WebDownLoadViewController *lViewController=[[WebDownLoadViewController alloc]init];
    lViewController.webDownLoadDelegate=self;
    lViewController.urlString=self.shareString;
    [self presentViewController:lViewController animated:YES completion:nil];
}

- (IBAction)duqushuji:(UIButton *)sender {
    NSLog(@"%@",[BookManager share].books);
    Book *lBook=[[BookManager share].books objectAtIndex:0];
    NSString *l=[lBook getHtmlStringByChapterIndex:lBook.chapterNumber-1];
}

#pragma mark - BaiduWeb Delegate
-(void)baiduWebViewController:(BaiduWebViewController *)baiduWebViewController selectedShareURL:(NSString *)urlString andFileName:(NSString *)fileName{
    self.shareString=urlString;
    NSLog(@"BaiduWeb:\nFileName:%@,FilePath:%@",fileName,urlString);
}
-(void)baiduWebViewControllerDidCancel:(BaiduWebViewController *)baiduWebViewController{
    NSLog(@"Cancel");
}
#pragma mark - WebDownLoad Delegate
-(void)webDownLoadViewController:(WebDownLoadViewController *)webDownLoadViewController selectedShareURL:(NSString *)urlString andFileName:(NSString *)fileName{
    NSLog(@"WebDownLoad:\nFileName:%@,FilePath:%@",fileName,urlString);
    
    [[DownLoadManager share]startDownloadFileWithFileName:fileName andFileURLString:urlString];
}
-(void)webDownLoadViewControllerDidCancel:(WebDownLoadViewController *)webDownLoadViewController{
    NSLog(@"Cancel");
}
@end
