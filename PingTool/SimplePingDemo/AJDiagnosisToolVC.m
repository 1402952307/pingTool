//
//  AJDiagnosisToolVC.m
//  SimplePingDemo
//
//  Created by mac02 on 2020/11/4.
//  Copyright © 2020 wanghe. All rights reserved.
//

#import "AJDiagnosisToolVC.h"
#import "WHPingTester.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/utsname.h> // 获取手机型号、

@interface AJDiagnosisToolVC ()<WHPingDelegate>
{
    UILabel* _pingLabel;
}
@property(nonatomic, strong) WHPingTester* pingTester;
@property(nonatomic, assign) int totalCount;
@property(nonatomic, assign) int totalTime;
@property(nonatomic, strong) UITextView *txtView_log;
@end

@implementation AJDiagnosisToolVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    _pingLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 100, 100, 50)];
    _pingLabel.textColor = [UIColor blackColor];
    _pingLabel.font = [UIFont systemFontOfSize:42.0];
    _pingLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_pingLabel];
    
    self.txtView_log = [[UITextView alloc] initWithFrame:CGRectZero];
    self.txtView_log.layer.borderWidth = 1.0f;
    self.txtView_log.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.txtView_log.backgroundColor = [UIColor whiteColor];
    self.txtView_log.font = [UIFont systemFontOfSize:10.0f];
    self.txtView_log.textAlignment = NSTextAlignmentLeft;
    self.txtView_log.scrollEnabled = YES;
    self.txtView_log.editable = NO;
    self.txtView_log.frame =
        CGRectMake(0.0f, 180.0f, self.view.frame.size.width, self.view.frame.size.height - 180.0f);
    [self.view addSubview:self.txtView_log];

    [self getBaseInfo];

    //ping
//    self.pingTester = [[WHPingTester alloc] initWithHostName:@"www.baidu.com"];
//    self.pingTester.delegate = self;
//    [self.pingTester startPing];
    



    NSMutableArray *pingArray = [NSMutableArray arrayWithArray:@[@"www.baidu.com",@"www.pgyer.com"]];

    self.totalCount = 0;

    static dispatch_source_t _timer;

    __weak typeof(self) weakSelf = self;
    //设置时间间隔
    NSTimeInterval period = 1.f;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);

    // 事件回调
    dispatch_source_set_event_handler(_timer, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            int index = weakSelf.totalCount / 3;

            weakSelf.totalCount++;

            NSString *hostName = pingArray[index];

//            NSLog(@"传----%@",hostName);
            //ping
            self.pingTester = [[WHPingTester alloc] initWithHostName:hostName];
            self.pingTester.delegate = self;
            [self.pingTester startPing];
            //网络请求 doSomeThing...


            
            if (self.totalCount == 6) {
                dispatch_suspend(_timer);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self addInfo:[NSString stringWithFormat:@"\n"]];
                    for (int i = 0; i < 3; i++) {
                        NSURL *url = [NSURL URLWithString:@"http://push.iotcplatform.com/tpns?cmd=client&token=edb8a14e7a56844abe812b1c58720cf896f586a5f5eb2932bce48312ad35dba6&appid=com.ansjer.zccloud&dev=0&lang=zh_CN&udid=FFC33E64-AB33-4808-B48A-0BC9EF85172B&os=ios&osver=14.1&appver=2020102701&model=iPhone"];
                        //註冊device
                        
                        NSDate *beginDate = [NSDate date];
                        NSString *registerResult = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                        int delayTime = [[NSDate date] timeIntervalSinceDate:beginDate] * 1000;
                        
                        
                        if ([registerResult rangeOfString:@"200"].location != NSNotFound) {
                            
                            NSLog(@"注册成功");
                            [self addInfo:[NSString stringWithFormat:@"--------------push.iotcplatform.com 连接成功 ----------------%dms",delayTime]];
                        } else {
                            [self addInfo:[NSString stringWithFormat:@"--------------push.iotcplatform.com 连接失败 ----------------0ms"]];
                        }
                    }
                    [self addInfo:[NSString stringWithFormat:@"\n"]];
                    
                });
                
            }

        });
    });

    // 开启定时器
    dispatch_resume(_timer);
  
    
}


- (void) getBaseInfo {
    
    if ([self.txtView_log.text isEqualToString:@""]) self.txtView_log.text = @"开始诊断...";
    
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

//     CFShow(infoDictionary);
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    [self addInfo:[NSString stringWithFormat:@"应用名称：%@",app_Name]];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [self addInfo:[NSString stringWithFormat:@"应用版本：%@",app_Version]];
    // app build版本
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    [self addInfo:[NSString stringWithFormat:@"build版本：%@",app_build]];
    [self addInfo:[NSString stringWithFormat:@"用户账号：%@",@"15915965549"]];

    NSString* userPhoneName = [[UIDevice currentDevice] name];
    [self addInfo:[NSString stringWithFormat:@"手机别名：%@",userPhoneName]];
    //设备名
    NSString* deviceName = [[UIDevice currentDevice] systemName];
    [self addInfo:[NSString stringWithFormat:@"机器类型：%@",deviceName]];
    
    
    //输出机器信息
    UIDevice *device = [UIDevice currentDevice];
    [self addInfo:[NSString stringWithFormat:@"机器类型: %@", [device systemName]]];
    [self addInfo:[NSString stringWithFormat:@"系统版本: %@", [device systemVersion]]];
    [self addInfo:[NSString stringWithFormat:@"手机型号：%@",[self getCurrentDeviceModel]]];
    NSString *currentNetWork = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentNetworkStatus"];
    [self addInfo:[NSString stringWithFormat:@"当前网络：%@",currentNetWork]];
    
    
//    if (!_deviceID || [_deviceID isEqualToString:@""]) {
    NSString *deviceID = [self uniqueAppInstanceIdentifier];
//    }
    [self addInfo:[NSString stringWithFormat:@"UUID: %@", deviceID]];
    
    NSString *totalSpace = [self usedSpaceAndfreeSpace];
    [self addInfo:[NSString stringWithFormat:@"%@", totalSpace]];
    

    NSString *carrierName = @"";
    NSString *ISOCountryCode = @"";
    NSString *MobileCountryCode = @"";
    NSString *MobileNetCode = @"";
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    if (carrier != NULL) {
        carrierName = [carrier carrierName];
        ISOCountryCode = [carrier isoCountryCode];
        MobileCountryCode = [carrier mobileCountryCode];
        MobileNetCode = [carrier mobileNetworkCode];
    } else {
        carrierName = @"";
        ISOCountryCode = @"";
        MobileCountryCode = @"";
        MobileNetCode = @"";
    }

    [self addInfo:[NSString stringWithFormat:@"运营商: %@", carrierName]];
    [self addInfo:[NSString stringWithFormat:@"ISOCountryCode: %@", ISOCountryCode]];
    [self addInfo:[NSString stringWithFormat:@"MobileCountryCode: %@", MobileCountryCode]];
    [self addInfo:[NSString stringWithFormat:@"MobileNetworkCode: %@", MobileNetCode]];

    
    [self addInfo:[NSString stringWithFormat:@"\n"]];
    
    
}

- (void) addInfo:(NSString *)info {
    self.txtView_log.text = [NSString stringWithFormat:@"%@\n%@",self.txtView_log.text,info];
}


#pragma mark ping的回调
- (void) didPingSucccessWithTime:(float)time withHostName:(NSString *)hostName withError:(NSError *)error
{
    if(error){
        NSLog(@"网络有问题");
    }else{
//        _pingLabel.text = [[NSString stringWithFormat:@"%d", (int)time] stringByAppendingString:@"ms"];
//        NSLog(@"hostName = %@============延时 = %@",hostName,[[NSString stringWithFormat:@"%d", (int)time] stringByAppendingString:@"ms"]);
        
        self.totalTime = self.totalTime + time;
        [self recordStepInfo:hostName withTime:(int)time];
        
        _pingLabel.text = [NSString stringWithFormat:@"%d%%",self.totalCount * (100 / 6)];
        
    }

    
}

/**
 * 如果调用者实现了stepInfo接口，输出信息
 */
- (void)recordStepInfo:(NSString *)hostName withTime:(int)time {
    
    if (hostName == nil) hostName = @"";
    
        
    NSString *tmpLog = [NSString stringWithFormat:@"诊断域名：%@--------%@",hostName,[[NSString stringWithFormat:@"%d", (int)time] stringByAppendingString:@"ms"]];
    
    self.txtView_log.text = [NSString stringWithFormat:@"%@\n%@",self.txtView_log.text,tmpLog];
    if (self.totalCount % 3 == 0) {
        
        self.txtView_log.text = [NSString stringWithFormat:@"%@\n%@",self.txtView_log.text,[NSString stringWithFormat:@"-------------- 当前平均延时：%lf --------------",self.totalTime / 3.0]];
        self.totalTime = 0;
        
    }
    
}



/**
 * 获取手机型号
 */
- (NSString *)getCurrentDeviceModel{
   struct utsname systemInfo;
   uname(&systemInfo);
   
   NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
   
   
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
    if ([deviceModel isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([deviceModel isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceModel isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
    if ([deviceModel isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";

    if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
    if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";

    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceModel;
}


/**
 * 获取deviceID
 */
- (NSString *)uniqueAppInstanceIdentifier
{
    NSString *app_uuid = @"";
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    app_uuid = [NSString stringWithString:(__bridge NSString *)uuidString];
    CFRelease(uuidString);
    CFRelease(uuidRef);
    
    NSString *tempApnsTokenStr = @"";
    //iOS13获取Token有变化 Xcode11打的包
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13) {
//        if (![apnsTokenData isKindOfClass:[NSData class]]) {
//            return;
//        }
//        const unsigned *tokenBytes = (const unsigned *)[apnsTokenData bytes];
//        tempApnsTokenStr = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
//                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
//                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
//                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
//
//    } else {
        
        tempApnsTokenStr = [NSString
                       stringWithFormat:@"%@",app_uuid];
        tempApnsTokenStr = [tempApnsTokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
        tempApnsTokenStr = [tempApnsTokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        tempApnsTokenStr = [tempApnsTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        tempApnsTokenStr = [tempApnsTokenStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
//    }
    
    return tempApnsTokenStr;
}

/**
 * 获取手机大小
 */
-(NSString *)usedSpaceAndfreeSpace{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSFileManager* fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    NSString *logStr = [NSString stringWithFormat:@"总空间：%0.1fG-----剩余空间%0.1fG",[totalSpace longLongValue]/1024.0/1024.0/1024.0,[freeSpace longLongValue]/1024.0/1024.0/1024.0];
        NSLog(@"str = %@",logStr);
    return logStr;
}


@end

