//
//  Temperature.h
//  vsonCare
//
//  Created by kakaxi on 2017/3/27.
//  Copyright © 2017年 VSON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Temperature : NSObject


@property(nonatomic,copy) NSString *BLEMac;
@property(nonatomic,copy) NSString *recordMin;          //yyyyMMddHHmm
@property(nonatomic,copy) NSString *recordHour;         //yyyyMMddHH
@property(nonatomic,copy) NSString *recordDate;         //yyyyMMdd
@property(nonatomic,copy) NSString *timeFormat;         //yyyy-MM-dd HH:mm:ss
@property(nonatomic,assign) float  temperatureValue;    //value


@end
