//
//  DownloadViewController.m
//  BaiduWeb
//
//  Created by admin001 on 14-10-8.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadCell.h"
#define DOWNLOAD_CELL_ID @"DownloadCellID"
@interface DownloadViewController ()
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UIViewController *myRootViewcontroller;
@end

@implementation DownloadViewController

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
    
    self.tableView=[[UITableView alloc]initWithFrame:self.myRootViewcontroller.view.frame style:UITableViewStylePlain];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView registerNib:[UINib nibWithNibName:@"DownloadCell" bundle:nil] forCellReuseIdentifier:DOWNLOAD_CELL_ID];
    [self.myRootViewcontroller.view addSubview:self.tableView];
}
-(void)setupNaviagtionBar{
    self.myRootViewcontroller.title=@"下载列表";
    UIBarButtonItem *lLeftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick:)];
    self.myRootViewcontroller.navigationItem.leftBarButtonItem=lLeftBarButtonItem;
}

-(void)leftBarButtonClick:(UIBarButtonItem *)sender{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - TableView Delegate
#pragma mark - TableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [DownLoadManager share].downloadInfos.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DownloadCell *lCell=(DownloadCell *)[tableView dequeueReusableCellWithIdentifier:DOWNLOAD_CELL_ID];
    NSInteger row=[indexPath row];
    ASIHTTPRequest *lRequest=[[DownLoadManager share].downloadInfos objectAtIndex:row];
    [lCell setCellRequest:lRequest];
    return lCell;
}
@end
