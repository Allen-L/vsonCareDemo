//
//  vsonCare.h
//  vsonCare
//
//  Created by kakaxi on 2017/3/10.
//  Copyright © 2017年 VSON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Temperature.h"

#define IsDisconnectedUserActive  @"IsDisconnectedUserActive"
#define BLE_MAC_CONNECTED         @"currentPeripheralIdentifier"



//SINGLETON
#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}


typedef NS_ENUM(NSInteger, Const_ble_status) {
    const_ble_status_scan = 0,
    const_ble_status_scaning = 1,
    const_ble_status_connecting = 2,
    const_ble_status_connceted = 3,
    const_ble_status_disconnected = 4
};

typedef NS_ENUM(NSInteger, Const_receive_data_type) {
    const_invalid_data = -1,      //Invalid data
    const_drink_one_more = 0,     //drink data
    const_charge_status = 1,      //current peripheral battery state
    const_device_setSuccess = 2,  //setSuccess
    const_generor_comm_data = 3   //General data
};

typedef NS_ENUM(NSInteger, SetPeripheralSuccessType) {
    SuccessType_CallBrate = 0,      //Deprecated
    SuccessType_SetName   = 1,      //Set Name Success
    SuccessType_Bind      = 2,      //Deprecated
    SuccessType_UnBind    = 3,      //Deprecated
    SuccessType_Init      = 4,      //init Success
    SuccessType_Normal    = 5,      //General Settings peripherals, such as modified water plan, switch peripherals buzzer Success
    SuccessType_HistoryRecord  = 6 , //peripheral Device HistoryRecord  send over Success
    DeviceFindPhone       = 7        //peripheral Device want to find the Phone
};

#pragma mark
#pragma mark-All of the protocol, please implement in your program

@protocol VsonBLEDelegate

@optional

/**
 *@brief    This method is active when peripherals to mobile phones to send data by the method called, all of the peripherals sent to mobile phone Numbers are callback this method
 *@param receiveData  phone receive data
 *@param length       data length
 *@param dataType     data type
 */
//-(void) peripheralDidUpdateValue:(NSData *)receiveData DataLength:(UInt16)length DataType:(Const_receive_data_type)dataType;

@optional
/**
 *@brief This method is that when you call a method  -(int) scanPeripheralsWithTimer:(int) timeout  connectedPeripheralUUID:(NSString *)PeripheralUUID; ，Timer stopScan, is returned to you scan to the total number of peripherals
 *@param peripherals_name  the array name of peripherals
 */

@optional
-(void) scanResult:(NSMutableArray *)peripherals_name;

/**
 *@brief This method is when peripheral bluetooth state change callback methods, such as have connected/disconnection
 *@param inStatuCode Current state of the peripheral
 */
@optional
-(void) peripheralConnectStateChanged:(Const_ble_status)inStatuCode;

@optional
/**
 *@brief  This Method is used to show that has been connected to the peripherals
 */
-(void)afterConnectedPeripheral;

@optional
/**
 *@brief This method is when phone set peripheral, set up the success will callback method, you need to determine type of success, to perform the corresponding operation
 *@param SuccessType Set the type of success
 */
-(void) setPeripheralSuccessResponse:(SetPeripheralSuccessType)SuccessType;

@optional
/**
 *@brief This method is when peripheral want to find you Phone
 */
-(void) peripheralWantToFindPhone;

@optional
/**
 *@brief  This Method is used to show that receive RSSI
 */
-(void)receiveRSSI:(int)rssi;


@optional
/**
 *@brief  This Method is used to show that receive peripheral current battery
 */
-(void)receiveBattery:(int)battery;

@optional
/**
 *@brief    Send the history of the stored data length on its own hardware, the app needs to respond to his database about the peripheral inside a historical data and the latest ,judgment by the hardware, decide whether to return to historical data
 */
-(void)receiveCanQueryHistoryDataMessage;

@optional
/**
 *@brief  This Method is used to show that receive temperature;for history data,perhaps the multiple temperature
 *@param objs   The set of temperature
 *@param type   temperature data type, 1:data for now   2:data for history
 */
-(void)receiveTemperatureData:(NSMutableArray *)objs Type:(int)type;

@end


@interface vsonCare : NSObject
@property (nonatomic,assign) id <VsonBLEDelegate> delegate;
@property (strong, nonatomic)  NSMutableArray *peripherals;
@property (strong, nonatomic)  NSMutableArray *peripherals_name;

AS_SINGLETON(vsonCare)
/**
 *@brief This method is used for active scan peripherals,
 *@param timeout           Scan time for timer
 *@param PeripheralUUID    last time had connected peripherals UUID,or you can set nil/null
 */
-(int) scanPeripheralsWithTimer:(int)timeout  connectedPeripheralUUID:(NSString *)PeripheralUUID;

/**
 *@brief  This method is used to stop manager scan peripheral
 */
-(void) stopScan;

/**
 *@brief  This method is used to check whether the current connection of peripheral you is still in the connection status  ture: show already connected  false:not connect
 */
-(BOOL) checkPeripheralConnectStatus;

/**
 *@brief   Method is used to connect you to specify an array subscript peripherals, when you call after scanning methods, will give you a scan to peripheral array, by specifying the array subscript to connect to the peripherals, the return value for the current want to link the peripheral UUID/identifier
 *@param    inindex    Want to connect a peripheral array index
 *@result   identifier for you connect
 */
-(NSString*) connectPeripheralWithIndex:(NSInteger)inindex;

/**
 *@brief This method is applied to disconnect peripherals
 */
-(void) disConnectPeripheral;

/**
 *@brief This method is read peripherals current RSSI
 */
-(void) readRSSI;


/**
 *@brief This method is read peripherals current battery
 */
-(void) readBattery;

/**
 *@brief Initialization method is used to send data to the peripherals, the method is used to initialize the weight of the cup mat, also is the own weight of calibration coasters, send data should prompt the user before take off cup mat cup body
 */
-(void) SendInitDeviceWeightToDevice;

/**
 *@brief Response to hardware, has received a historical data package
 */
-(void) SendReceiveHistoryTemperatureToDevice;

/**
 *@brief According to the time request to historical temperature records to hardware
 *@param time      data of query time
 */
-(void) sendRequestQueryHistoryTemperatureRecordToDeviceWithTime:(Byte * )time;


/**
 *@brief Remove the temperature history data of hardware
 */
-(void) SendClearHistoryTemperatureDataCommandToDevice;










// Don't need to call the following methods

/**
 *@brief This method is used to send data to the peripherals peripherals whether to open the buzzer, speaker
 *@param isNeedOpen     Whether you need to open the speaker
 */
-(void) sendOpenSPKDataToDevice:(BOOL)isNeedOpen;


/**
 *@brief This method is used to send data to the peripherals peripherals whether to can use the buzzer, speaker
 *@param isEnable     Whether you need to enable the speaker
 */
-(void) sendEnableSPKDataToDevice:(BOOL)isEnable;

/**
 *@brief This method is used to send data to the peripherals peripherals for temperature collect Interval
 *@param interval     collect Interval
 */
-(void) sendCollectIntervalDataToDevice:(int)interval;


/**
 *@brief Method is used to send user set the new name for the peripheral devices, type in Chinese is not currently supported
 *@param indata     Need to send the name of the data
 */
-(void) sendDeviceNewNameToDeviceWithName:(NSData * )indata;

/**
 *@brief Method is used to set the type of data to the peripherals
 *@param indata  Need to send the set of the data
 */
-(void) sendSetTypeDataToDevice:(NSData * )indata;


@end
