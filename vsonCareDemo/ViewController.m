//
//  ViewController.m
//  vsonCareDemo
//
//  Created by kakaxi on 2017/3/13.
//  Copyright © 2017年 VSON. All rights reserved.
//

#import "ViewController.h"
#import "vsonCare.h"
#import "DataViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>


#define SCREEN_WIDTH    [[UIScreen mainScreen]bounds].size.width
#define SCREEN_HEIGHT   [[UIScreen mainScreen]bounds].size.height
static NSString * cell_iden = @"cellIden";

@interface ViewController ()<VsonBLEDelegate,UITableViewDelegate,UITableViewDataSource>
{
    vsonCare *m_vsonCare;
    UITableView *m_tableViewItem;
    NSMutableArray *m_array_items;
    UIActivityIndicatorView *activity;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    m_vsonCare = [vsonCare sharedInstance];
    m_vsonCare.delegate = self;
    
    
    UIBarButtonItem *barItem_right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(scanDevice:)];
    barItem_right.title = @"scan";
    self.navigationItem.rightBarButtonItem = barItem_right;
    
    
    m_tableViewItem = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    m_tableViewItem.dataSource = self;
    m_tableViewItem.delegate = self;
    m_array_items = [[NSMutableArray alloc]init];
    
    [m_array_items addObject:@"Please click the refresh button, scan"];
    [self.view addSubview:m_tableViewItem];
    
    activity = [[UIActivityIndicatorView alloc] initWithFrame:self.view.bounds];
    activity.backgroundColor = [UIColor lightGrayColor];
    activity.alpha = 0.7;
    activity.center = self.view.center;
    //设置显示的类型
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:activity];
    
}

-(void)viewWillAppear:(BOOL)animated{
    m_vsonCare.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated{
    m_vsonCare.delegate = nil;
}

#pragma Fun-Self
-(void)scanDevice:(id)sender{
    
    [activity startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [activity stopAnimating];
    });
    
    [m_vsonCare scanPeripheralsWithTimer:7.0 connectedPeripheralUUID:nil];
   
}

#pragma UITableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  55;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return m_array_items.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell_item = [tableView dequeueReusableCellWithIdentifier:cell_iden];
    if (!cell_item) {
        cell_item = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_iden];
    }
    cell_item.textLabel.text = [m_array_items objectAtIndex:indexPath.row];
    return cell_item;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    
    [m_array_items removeAllObjects];
    [m_array_items addObject:@"Please click the refresh button, scan"];
    [m_tableViewItem reloadData];
    
    [m_vsonCare connectPeripheralWithIndex:indexPath.row];
    
    DataViewController *dataVC = [[DataViewController alloc]init];
    dataVC.title = @"Data";
    [self.navigationController pushViewController:dataVC animated:YES];
    
}

#pragma VsonBLEDelegate Delegate
-(void) scanResult:(NSMutableArray *)peripherals_name;
{
    [m_array_items removeAllObjects];
    m_array_items = [peripherals_name mutableCopy];
    [m_tableViewItem reloadData];
    
    if (peripherals_name.count < 1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Note" message:@"There is no scan to the device, please scan again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}
/*
-(void) peripheralConnectStateChanged:(Const_ble_status)inStatuCode;
{
    NSLog(@"peripheralConnectStateChanged = %ld",(long)inStatuCode);
}

-(void)afterConnectedPeripheral;
{
 
}
-(void) setPeripheralSuccessResponse:(SetPeripheralSuccessType)SuccessType;
{
}
-(void) peripheralWantToFindPhoneWithPackageNumber:(int)packageNumber;
{
}
-(void)receiveRSSI:(int)rssi;
{
    
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
