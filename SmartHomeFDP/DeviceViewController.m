//
//  LJHotStatusViewController.m
//  NewProject
//
//  Created by eddie on 14-9-4.
//  Copyright (c) 2014年 eddie. All rights reserved.
//

#import "DeviceViewController.h"
#import "RMDeviceManager.h"
#import "BtnStudyViewController.h"
#import "ChangeRemoteNameViewController.h"
#import "ProgressHUD.h"
#import "StatisticFileManager.h"
#import "CaoStudyModel.h"
#import "LGSocketServe.h"
#import "JSONKit.h"
#import "ProgressHUD.h"
#import "NetworkStatus.h"
@interface DeviceViewController ()
{
    //RMDeviceManager *rmDeviceManager;
    dispatch_queue_t networkQueue;

}
@end

@implementation DeviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //隐藏tabbar工具条
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    networkQueue = dispatch_queue_create("BroadLinkRM2NetworkQueue", DISPATCH_QUEUE_SERIAL);
//    rmDeviceManager=[[RMDeviceManager alloc]init];
//    [rmDeviceManager initRMDeviceManage];
    self.view.backgroundColor = [UIColor whiteColor];

    /*Add changeButtonItem button*/
    UIBarButtonItem *changeNameItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(changeBarButtonItemClicked:)];
    //[changeButtonItem setTintColor:[UIColor colorWithRed:132.0f/255.0f green:174.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    [self.navigationItem setRightBarButtonItem:changeNameItem];

}

- (void) viewWillAppear:(BOOL)animated
{
    RMDeviceManager *rmDeviceManager=[[RMDeviceManager alloc]init];
    [rmDeviceManager initRMDeviceManage];
    NSDictionary *dicDevices=[rmDeviceManager.RMDeviceArray objectAtIndex:_rmDeviceIndex];
    [self.navigationItem setTitle:[dicDevices objectForKey:@"name"]];
    //NSLog(@"plist中第 %d 项",_rmDeviceIndex);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(int)addDevice
{
    RMDeviceManager *rmDeviceManager=[RMDeviceManager createRMDeviceManager];
    //[rmDeviceManager initRMDeviceManage];
    
    RMDevice *rmDevice=[RMDevice itemDevice];
    rmDevice.mac = _info.mac;
    if ([_remoteType isEqualToString:@"TV"]) {
        rmDevice.type=_remoteType;
        int remoteCount = [rmDeviceManager getRemoteCount:_remoteType];
        rmDevice.name=[@"电视" stringByAppendingFormat:@"%@",[NSNumber numberWithInt:remoteCount+1]];
        NSArray *tvBtnName = [[NSArray alloc] initWithObjects:@"电视开关",@"电视静音",@"电视向上",@"电视向下",@"电视向左",@"电视向右",@"电视确定", nil];
        for (int i = 0; i<7; i++) {
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[[NSNumber alloc]initWithInt:i], @"buttonId",@"",@"sendData",@"",@"buttonInfo",[tvBtnName objectAtIndex:i],@"btnName",nil];
            [rmDevice addRMButton:dic];
        }
    } else if([_remoteType isEqualToString:@"AirCondition"]){
        rmDevice.type=_remoteType;
        int remoteCount = [rmDeviceManager getRemoteCount:_remoteType];
        rmDevice.name=[@"空调" stringByAppendingFormat:@"%@",[NSNumber numberWithInt:remoteCount+1]];
        
        NSArray *airBtnName = [[NSArray alloc] initWithObjects:@"空调开关",@"空调加",@"空调减", nil];
        
        for (int i = 0; i<3; i++) {
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[[NSNumber alloc]initWithInt:i], @"buttonId",@"",@"sendData",@"",@"buttonInfo",[airBtnName objectAtIndex:i],@"btnName",nil];
            [rmDevice addRMButton:dic];
        }
    }else if([_remoteType isEqualToString:@"Curtain"]){
        rmDevice.type=_remoteType;
        int remoteCount = [rmDeviceManager getRemoteCount:_remoteType];
        rmDevice.name=[@"窗帘" stringByAppendingFormat:@"%@",[NSNumber numberWithInt:remoteCount+1]];
        NSArray *curtainBtnName = [[NSArray alloc] initWithObjects:@"窗帘关",@"窗帘开",@"窗帘停", nil];
        
        for (int i = 0; i<3; i++) {
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[[NSNumber alloc]initWithInt:i], @"buttonId",@"",@"sendData",@"",@"buttonInfo",[curtainBtnName objectAtIndex:i],@"btnName",nil];
            [rmDevice addRMButton:dic];
        }
    }else if([_remoteType isEqualToString:@"Projector"]){
        rmDevice.type=_remoteType;
        int remoteCount = [rmDeviceManager getRemoteCount:_remoteType];
        rmDevice.name=[@"投影仪" stringByAppendingFormat:@"%@",[NSNumber numberWithInt:remoteCount+1]];
        NSArray *projectorBtnName = [[NSArray alloc] initWithObjects:@"投影仪关",@"投影仪开", nil];
        
        for (int i = 0; i<2; i++) {
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[[NSNumber alloc]initWithInt:i], @"buttonId",@"",@"sendData",@"",@"buttonInfo",[projectorBtnName objectAtIndex:i],@"btnName",nil];
            [rmDevice addRMButton:dic];
        }
    }else if([_remoteType isEqualToString:@"Light"]){
        rmDevice.type=_remoteType;
        int remoteCount = [rmDeviceManager getRemoteCount:_remoteType];
        rmDevice.name=[@"电灯" stringByAppendingFormat:@"%@",[NSNumber numberWithInt:remoteCount+1]];
        NSArray *lightBtnName = [[NSArray alloc] initWithObjects:@"关灯",@"开灯", nil];
        
        for (int i = 0; i<2; i++) {
            NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:[[NSNumber alloc]initWithInt:i], @"buttonId",@"",@"sendData",@"",@"buttonInfo",[lightBtnName objectAtIndex:i],@"btnName",nil];
            [rmDevice addRMButton:dic];
        }
    }else if([_remoteType isEqualToString:@"Custom"]){
        rmDevice.type=_remoteType;
        int remoteCount = [rmDeviceManager getRemoteCount:_remoteType];
        rmDevice.name=[@"自定义" stringByAppendingFormat:@"%@",[NSNumber numberWithInt:remoteCount+1]];
        
    }else
    {
        //error
        return -1;
    }
    
   
    //向服务器发送添加remote的信息
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *remoteDic = [[NSMutableDictionary alloc] init];
        [remoteDic setObject:@"addRemote" forKey:@"command"];
        [remoteDic setObject:_info.mac forKey:@"mac"];
        [remoteDic setObject:rmDevice.name forKey:@"name"];
        [remoteDic setObject:rmDevice.type forKey:@"type"];
        //NSLog(@"TV =%@",remoteDic);
        [SmartHomeAPIs AddRemote:remoteDic];
    });
    
    NSLog(@"%@ add to plist",rmDevice);
    return [rmDeviceManager addRMDeviceInfoIntoFile:rmDevice];
}

- (IBAction)buttonClicked:(UIButton *)sender {
    RMDeviceManager *rmDeviceManager=[[RMDeviceManager alloc]init];
    [rmDeviceManager initRMDeviceManage];
    NSDictionary *dicDevices=[rmDeviceManager.RMDeviceArray objectAtIndex:_rmDeviceIndex];
    //RMDevice *device = [rmDeviceManager getRMDevice:super.rmDeviceIndex];
    NSArray *arrayBtn = [dicDevices objectForKey:@"buttonArray"];
    //NSLog(@"arrayBtn %@",arrayBtn);
    UIButton *button = (UIButton *) sender;
    NSDictionary * dicBtn = [arrayBtn objectAtIndex:button.tag];
    _btnId = button.tag;
    //[self operateStatistics:[dicDevices objectForKey:@"type"]];
    //NSLog(@"_rmDeviceIndex %i dicBtn %@",_rmDeviceIndex,dicBtn);
    if ([[dicBtn objectForKey:@"sendData"] isEqualToString:@""]) {
        BtnStudyViewController *btnStudyViewController = [[BtnStudyViewController alloc] init];
        btnStudyViewController.navigationItem.title = @"学习模式";
        btnStudyViewController.rmDeviceIndex = _rmDeviceIndex;
        btnStudyViewController.info = _info;
        btnStudyViewController.btnId = button.tag;
        [self.navigationController pushViewController:btnStudyViewController animated:YES];
    }else{

        RMDevice *btnDevice = [rmDeviceManager getRMDevice:self.rmDeviceIndex];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:104] forKey:@"api_id"];
        [dic setObject:@"send data" forKey:@"command"];
        [dic setObject:self.info.mac forKey:@"mac"];
        [dic setObject:[dicBtn objectForKey:@"sendData"] forKey:@"data"];
        [dic setObject:[NSNumber numberWithInt:0] forKey:@"message_id"];
//        NSLog(@"dic=%@",dic);

        
        NSString *wifiName = [[NetworkStatus sharedNetworkStatus] getCurrentWiFiSSID];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([wifiName isEqualToString:[defaults objectForKey:@"wifiName"]]) {
            LGSocketServe *socketServe = [LGSocketServe sharedSocketServe];
            socketServe.mac = self.info.mac;
            
            socketServe.block = ^(NSDictionary *dic){
                NSString * code = [dic objectForKey:@"code"];
                if ([code intValue] == 0) {
                    //成功进入学习模式，提示用户操作遥控器
                    //data = [caoStudyModel caoGetControlData];
                    
                    [ProgressHUD showSuccess:@"操作成功"];
                    
                } else {
                    [ProgressHUD showError:[NSString stringWithFormat:@"错误码＝%i",[code intValue]]];
                }
                
                //NSLog(@"%@", [responseData objectFromJSONData]);
                dispatch_async(serverQueue, ^{
                    int success = ([[dic objectForKey:@"code"] intValue]==0) ? 0:1;
                    //NSLog(@"success = %d",success);
                    NSMutableDictionary *remoteDic = [[NSMutableDictionary alloc] init];
                    [remoteDic setObject:@"rm2Send" forKey:@"command"];
                    [remoteDic setObject:self.info.mac forKey:@"mac"];
                    [remoteDic setObject:btnDevice.name forKey:@"name"];
                    [remoteDic setObject:[NSNumber numberWithInt:button.tag] forKey:@"buttonId"];
                    [remoteDic setObject:[dicBtn objectForKey:@"sendData"] forKey:@"sendData"];
                    [remoteDic setObject:[NSNumber numberWithInt:success] forKey:@"success"];
                    [remoteDic setObject:[NSNumber numberWithInt:0] forKey:@"op_method"];
                    [SmartHomeAPIs Rm2SendData:remoteDic];
                });
            };
            
            //socket连接前先断开连接以免之前socket连接没有断开导致闪退
            [socketServe cutOffSocket];
            socketServe.socket.userData = SocketOfflineByServer;
            [socketServe startConnectSocket];
            //[dic setObject:@"54:4A:16:2E:2F:F3" forKey:@"mac"];
            //NSLog(@"dic=%@",dic);
            //发送消息 @"hello world"只是举个列子，具体根据服务端的消息格式
            NSData *requestData = [dic JSONData];
            NSString *josnString = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
            
            [socketServe sendMessage:josnString];
        }else{
            dispatch_async(networkQueue, ^{
                RMDevice *btnDevice = [rmDeviceManager getRMDevice:_rmDeviceIndex];
                
                CaoStudyModel *caoStudyModel = [CaoStudyModel studyModelWithBLDeviceInfo:_info rmDevice:btnDevice btnId:button.tag];
                int code = [[caoStudyModel caoSendControlData:[dicBtn objectForKey:@"sendData"]] intValue];
                if (code == 0) {
                    [self performSelectorOnMainThread:@selector(successWithMessage:) withObject:@"操作成功" waitUntilDone:YES];
                } else {
                    [self performSelectorOnMainThread:@selector(errorWithMessage:) withObject:@"失败，请重试！" waitUntilDone:YES];
                    
                }
            });
            //NSLog(@"发送 %@",[dicBtn objectForKey:@"sendData"]);
        }
    }
}

-(void) operateStatistics :(NSString*)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        StatisticFileManager * statisticManager = [StatisticFileManager createStatisticManager];
        [statisticManager statisticOperateWithType:type andBtnId:_btnId];
    });
}

- (void) successWithMessage:(NSString *)message {
    [ProgressHUD showSuccess:message];
}

- (void) errorWithMessage:(NSString *)message {
    [ProgressHUD showError:message];
}

- (IBAction)btnLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([sender.view isKindOfClass:[UIButton class]]) {
            //UIButton *button = (UIButton *)sender.view;
            //UIView *view = [longPress view];
            UIButton *btn = (UIButton *)sender.view;
           // NSLog(@"长按成功！！！！！！！！！！！%i",btn.tag);
            _btnId = btn.tag;
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"重设Button" message:@"重新设置按钮的语音命令或者操作码？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
  
        }
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        //// Yes condition
        NSLog(@"Yes");
        
        BtnStudyViewController *btnStudyViewController = [[BtnStudyViewController alloc] init];
        btnStudyViewController.navigationItem.title = @"学习模式";
        btnStudyViewController.rmDeviceIndex = _rmDeviceIndex;
        btnStudyViewController.info = _info;
        btnStudyViewController.btnId = _btnId;
        
        [self.navigationController pushViewController:btnStudyViewController animated:YES];
       
    } else {
        NSLog(@"No");
        ///// No condition
    }
}

- (void)changeBarButtonItemClicked:(UIBarButtonItem *)item
{
    ChangeRemoteNameViewController *changeRemoteNameViewController = [[ChangeRemoteNameViewController alloc] init];
    changeRemoteNameViewController.navigationItem.title = @"修改面板名称";
    changeRemoteNameViewController.rmDeviceIndex = _rmDeviceIndex;
    changeRemoteNameViewController.info = _info;
    changeRemoteNameViewController.btnId = _btnId;
    
    [self.navigationController pushViewController:changeRemoteNameViewController animated:YES];
}

@end

