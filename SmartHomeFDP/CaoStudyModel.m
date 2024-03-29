//
//  CaoStudyModel.m
//  SmartHomeFDP
//
//  Created by cisl on 15/9/22.
//  Copyright (c) 2015年 eddie. All rights reserved.
//

#import "CaoStudyModel.h"
#import "JSONKit.h"
#import "MJExtension.h"
#import "RMButton.h"
#import "SmartHomeAPIs.h"
#import "LGSocketServe.h"
@implementation CaoStudyModel

- (instancetype)initWithBLDeviceInfo :(BLDeviceInfo*)info  rmDevice:(RMDevice*) rmDevice btnId:(int)btnId;
{
    if(self = [super init])
    {
        _info = info;
        _rmDevice = rmDevice;
        _btnId = btnId;
        for (RMButton *btn in rmDevice.RMButtonArray) {
            if (btn.buttonId == btnId) {
                _btnDic = [btn keyValues];
            }
        }
    }
    return self;
}
+ (instancetype)studyModelWithBLDeviceInfo :(BLDeviceInfo*)info rmDevice:(RMDevice*) rmDevice btnId:(int)btnId;
{
    return [[self alloc] initWithBLDeviceInfo:info rmDevice:rmDevice btnId:btnId];
}

//////
- (instancetype)initWithArgument :(BLDeviceInfo*)info
{
    if(self = [super init])
    {
        _info = info;
    }
    return self;
}
+ (instancetype)studyModelWithArgument :(BLDeviceInfo*)info
{
    return [[self alloc] initWithArgument:info];
}
///////
- (instancetype)initWithBLDeviceInfo :(BLDeviceInfo*)info  btnDic:(NSDictionary*) btnDic btnId:(int)btnId
{
    if(self = [super init])
    {
        _info = info;
        _btnDic = btnDic;
        _btnId = btnId;
    }
    return self;
}
+ (instancetype)studyModelWithBLDeviceInfo :(BLDeviceInfo*)info btnDic:(NSDictionary*) btnDic btnId:(int)btnId
{
    return [[self alloc] initWithBLDeviceInfo:info btnDic:btnDic btnId:btnId];
}
////////

/*Study model start,rm2's red bulb light up*/
- (NSString *)caoStudyModelStart
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:102] forKey:@"api_id"];
    [dic setObject:@"study mode" forKey:@"command"];
    [dic setObject:_info.mac forKey:@"mac"];
    //[dic setObject:[NSNumber numberWithInt:0] forKey:@"message_id"];
    
    
    
    
    return [[SmartHomeAPIs CaoEnterStudy:dic] objectForKey:@"code"];
}


/*get control data*/
- (NSString *)caoGetControlData
{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:103] forKey:@"api_id"];
    [dic setObject:@"save data" forKey:@"command"];
    [dic setObject:_info.mac forKey:@"mac"];
//    [dic setObject:[NSNumber numberWithInt:_btnId] forKey:@"btnId"];
//    [dic setObject:@"" forKey:@"btnName"];
//    [dic setObject:@"" forKey:@"voice"];
//    [dic setObject:@"" forKey:@"deviceId"];
//    [dic setObject:@"" forKey:@"state"];

    //[dic setObject:[NSNumber numberWithInt:0] forKey:@"message_id"];
    NSDictionary *result = [SmartHomeAPIs CaoGetCode:dic];
    
    if ([[result objectForKey:@"code"] intValue] == 0)
    {
        NSString * data = [result objectForKey:@"data"];
        
        dispatch_async(serverQueue, ^{
            NSMutableDictionary *remoteDic = [[NSMutableDictionary alloc] init];
            [remoteDic setObject:@"rm2Study" forKey:@"command"];
            [remoteDic setObject:_info.mac forKey:@"mac"];
            [remoteDic setObject:[NSNumber numberWithInt:0] forKey:@"success"];
            [remoteDic setObject:_rmDevice.name forKey:@"name"];
            [remoteDic setObject:[NSNumber numberWithInt:_btnId] forKey:@"buttonId"];
            [remoteDic setObject:data forKey:@"sendData"];
            [SmartHomeAPIs Rm2StudyData:remoteDic];
        });
        
        
        return data;
    }
    return nil;
}

/*Send data command*/
- (NSString *)caoSendControlData:(NSString *)data
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:104] forKey:@"api_id"];
    [dic setObject:@"send data" forKey:@"command"];
    [dic setObject:_info.mac forKey:@"mac"];
    [dic setObject:data forKey:@"data"];
    //[dic setObject:[NSNumber numberWithInt:0] forKey:@"message_id"];
    
    NSDictionary *result = [SmartHomeAPIs CaoSendCode:dic];
    //NSLog(@"%@", [responseData objectFromJSONData]);
    dispatch_async(serverQueue, ^{
        int success = ([[result objectForKey:@"code"] intValue]==0) ? 0:1;

        
        NSMutableDictionary *remoteDic = [[NSMutableDictionary alloc] init];
        [remoteDic setObject:@"rm2Send" forKey:@"command"];
        [remoteDic setObject:_info.mac forKey:@"mac"];
        [remoteDic setObject:_rmDevice.name forKey:@"name"];
        [remoteDic setObject:[NSNumber numberWithInt:_btnId] forKey:@"buttonId"];
        [remoteDic setObject:data forKey:@"sendData"];
        [remoteDic setObject:[NSNumber numberWithInt:success] forKey:@"success"];
        [remoteDic setObject:[NSNumber numberWithInt:0] forKey:@"op_method"];
        [SmartHomeAPIs Rm2SendData:remoteDic];
    });
    
    return [result objectForKey:@"code"];
}

@end
