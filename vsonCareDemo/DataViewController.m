//
//  DataViewController.m
//  vsonCareDemo
//
//  Created by kakaxi on 2017/3/13.
//  Copyright © 2017年 VSON. All rights reserved.
//

#import "DataViewController.h"
#import "vsonCare.h"
#import "Temperature.h"
@interface DataViewController ()<VsonBLEDelegate>{
    
    vsonCare *m_vsonCare;
    
    UITextView *text_HistoryData;
    UITextView *text_DataNow;
    NSMutableString *string_HistoryData;
    NSTimer *timer_readRSSI;
    
    UILabel *lable_RSSI;
    UILabel *lable_Battery;
}

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    m_vsonCare = [vsonCare sharedInstance];
    m_vsonCare.delegate = self;
    
    
    float SCREEN_WIDTH  = [[UIScreen mainScreen]bounds].size.width;
    float SCREEN_HEIGHT = [[UIScreen mainScreen]bounds].size.height;
    
    string_HistoryData = [NSMutableString new];
    text_HistoryData= [[UITextView alloc]initWithFrame:CGRectMake(10, 64+20, SCREEN_WIDTH-20, SCREEN_HEIGHT*0.3)];
    text_HistoryData.editable = NO;
    text_HistoryData.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:text_HistoryData];
    
    text_DataNow= [[UITextView alloc]initWithFrame:CGRectMake(10, 64+SCREEN_HEIGHT*0.4, SCREEN_WIDTH-20, SCREEN_HEIGHT*0.2)];
    text_DataNow.editable = NO;
    text_DataNow.backgroundColor = [UIColor grayColor];
    [self.view addSubview:text_DataNow];
    
    lable_RSSI = [[UILabel alloc]initWithFrame:CGRectMake(10, 64+SCREEN_HEIGHT*0.6+10, SCREEN_WIDTH-20, 40)];
    lable_RSSI.text = @"RSSI = ";
    [self.view addSubview:lable_RSSI];
    
    lable_Battery = [[UILabel alloc]initWithFrame:CGRectMake(10, 64+SCREEN_HEIGHT*0.6+60, SCREEN_WIDTH-20, 40)];
    lable_Battery.text = @"Battery = ";
    [self.view addSubview:lable_Battery];
    
}

-(void)viewWillAppear:(BOOL)animated{
    m_vsonCare.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated{
    
    //  if you want to disconnect peripheral active ,please set values: YES
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsDisconnectedUserActive];
    [m_vsonCare disConnectPeripheral];
    m_vsonCare.delegate = nil;
}

-(void)connectField{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark_self

-(void)readPeripheralRSSI{
    [m_vsonCare readRSSI];
}


#pragma VsonBLEDelegate Delegate
/*
-(void) scanResult:(NSMutableArray *)peripherals_name;{

}
*/
-(void) peripheralConnectStateChanged:(Const_ble_status)inStatuCode;{
    NSLog(@"dataVC peripheralConnectStateChanged = %ld",(long)inStatuCode);
    switch (inStatuCode) {
        case const_ble_status_connceted:
        {
            NSLog(@"peripheral connected");
        }
            break;
        case const_ble_status_disconnected:
        {
            if (timer_readRSSI) {
                [timer_readRSSI invalidate];
                timer_readRSSI = nil;
            }
            NSLog(@"peripheral disconnected,you should remind the user，and stop read rssi");
        }
            break;
            
        default:
            break;
    }
}

-(void)afterConnectedPeripheral;{
    NSLog(@"dataVC afterConnectedPeripheral");
    if (timer_readRSSI) {
        [timer_readRSSI invalidate];
        timer_readRSSI = nil;
    }
    timer_readRSSI = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(readPeripheralRSSI) userInfo:nil repeats:YES];
}

-(void) setPeripheralSuccessResponse:(SetPeripheralSuccessType)SuccessType;{
     if (SuccessType == SuccessType_HistoryRecord) {
         NSLog(@"history data receive done,you can refresh view or you can each time to receive historical data refresh your interface");
     }
}
-(void) peripheralWantToFindPhone;{
    NSLog(@"receive peripheralWantToFindPhone,You can remind the user, such as alarm sound");
}

-(void)receiveRSSI:(int)rssi;{

    //NSLog(@"receiveRSSI = %d",rssi);
    lable_RSSI.text = [NSString stringWithFormat:@"RSSI = %d",rssi];
    
    if (rssi >= -100 && rssi < -90) {
        // The larger the value, the stronger the signal 1/2/3/4/5/6
        NSLog(@"Signal strength: 1");
    }else if (rssi  >= -90 && rssi < -80){
        NSLog(@"Signal strength: 2");
    }else if (rssi  >= -80 && rssi < -70){
        NSLog(@"Signal strength: 3");
    }else if (rssi  >= -70 && rssi < -60){
        NSLog(@"Signal strength: 4");
    }else if (rssi  >= -60 && rssi < -50){
        NSLog(@"Signal strength: 5");
    }else if (rssi  >= -50){
        NSLog(@"Signal strength: 6");
    }
}

-(void)receiveBattery:(int)battery;{
   
    // battery value is:  0--100
    
    //NSLog(@"receiveBattery = %d",battery);
    lable_Battery.text = [NSString stringWithFormat:@"Battery = %d",battery];
}

-(void)receiveCanQueryHistoryDataMessage;{
    
    
    // you need query from database for the BLEID corresponds to the latest of a temperature data record，Get record time, sent to the hardware，Time format must be  yyMMddHHmm,like this:
    
   
    
    /*
    NSString *str_identifierCurrent = [NSString new];
    str_identifierCurrent = [[NSUserDefaults standardUserDefaults]stringForKey:BLE_MAC_CONNECTED];
    NSString *time = [Database queryDateLatestTemperatureForID:str_identifierCurrent]; // yyMMddHHmm
    Byte queryTime[5] = {0};
    queryTime[0] = [[time substringWithRange:NSMakeRange(0, 2)] intValue];  //year
    queryTime[1] = [[time substringWithRange:NSMakeRange(2, 2)] intValue];   //month
    queryTime[2] = [[time substringWithRange:NSMakeRange(4, 2)] intValue];  //day
    queryTime[3] = [[time substringWithRange:NSMakeRange(6, 2)] intValue];  //hour
    queryTime[4] = [[time substringWithRange:NSMakeRange(8, 2)] intValue];  //min
    */
    
    
    Byte queryTime[5] = {0};
    queryTime[0] = 17;  //year
    queryTime[1] = 3;   //month
    queryTime[2] = 24;  //day
    queryTime[3] = 15;  //hour
    queryTime[4] = 37;  //min
    [m_vsonCare sendRequestQueryHistoryTemperatureRecordToDeviceWithTime:queryTime];
}

-(void)receiveTemperatureData:(NSMutableArray *)objs Type:(int)type;{
    if (objs.count < 1) {
        return;
    }
    switch (type) {
        case 1:
        {
            //data now,send a real-time data every five seconds, according to your demand, please save
            Temperature *tem = [objs firstObject];
            text_DataNow.text = [NSString stringWithFormat:@"BLEMac = %@ \r timeFormat = %@ \r recordMin = %@ \n temperature = %.1f",tem.BLEMac,tem.timeFormat,tem.recordMin,tem.temperatureValue];
        }
            break;
        case 2:
            
        {
            //data history
            //note: If the historical data of hardware for a few days, then complete historical data may take a few minutes
            for (int i=0; i<objs.count; i++) {
                Temperature *tem = [objs objectAtIndex:i];
                [string_HistoryData appendString:[NSString stringWithFormat:@"BLEMac = %@ timeFormat = %@ recordMin = %@ temperature = %.1f \n",tem.BLEMac,tem.timeFormat,tem.recordMin,tem.temperatureValue]];
                //you can save tem to database
            }
            text_HistoryData.text = string_HistoryData;
        }
            break;
        default:
            break;
    }
}

#pragma mark-Parase

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
