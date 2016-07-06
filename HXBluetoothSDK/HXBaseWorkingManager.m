//
//  HXBaseWorking.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/19.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseWorkingManager.h"
#import "HXBaseController.h"
#import "HXBaseError.h"

/**
 *  @author huangxiong, 2016/04/06 10:16:42
 *
 *  @brief 工作管理器, 单例
 *
 *  @since 1.0
 */
static HXBaseWorkingManager *baseWorkingManager = nil;

#pragma mark- Extension
@interface HXBaseWorkingManager () {
    
    /**
     *  @author huangxiong, 2016/04/06 10:18:00
     *
     *  @brief 控制器, 即对应的蓝牙协议的流程控制器
     *
     *  @since 1.0
     */
    HXBaseController *_controller;
    
    /**
     *  @author huangxiong, 2016/04/06 10:19:11
     *
     *  @brief 是否配置 _configWorkingManager
     *
     *  @since 1.0
     */
    BOOL _isConfigWorkingManager;
    
    /**
     *  @author huangxiong, 2016/04/06 10:19:27
     *
     *  @brief 配置文件字典
     *
     *  @since 1.0
     */
    NSDictionary *_configureFileRootDictionary;
    
    /**
     *  @author huangxiong, 2016/04/06 17:16:03
     *
     *  @brief 支持的协议
     *
     *  @since 1.0
     */
    NSString *_supportProtocol;
}

@end

#pragma mark- 实现
@implementation HXBaseWorkingManager

#pragma mark- 默认管理器
+ (instancetype)manager {
    
    // 如果已存在
    if (baseWorkingManager) {
        return baseWorkingManager;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baseWorkingManager = [[super alloc] init];
        
        // 暂未配置管理器
        baseWorkingManager->_isConfigWorkingManager = NO;
    });
    
    return baseWorkingManager;
}

+ (instancetype)managerWithConfiguresOfFile: (NSString *)fileName {
    
    // 如果已存在
    if (baseWorkingManager) {
        return baseWorkingManager;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baseWorkingManager = [[super alloc] init];
        
        if (baseWorkingManager) {
           HXBaseError *error = [baseWorkingManager setConfiguresOfFile: fileName];
            
            if (error) {
                NSAssert(!error, error.localizedDescription);
            }
        }
        
        // 暂未配置管理器
        baseWorkingManager->_isConfigWorkingManager = YES;
    });
    
    return baseWorkingManager;
}


- (HXBaseError *) setConfiguresOfFile: (NSString *)fileName {
    HXDEBUG;
    
    NSString *path = [[NSBundle mainBundle] pathForResource: fileName ofType: @"plist"];
    _configureFileRootDictionary = [NSDictionary dictionaryWithContentsOfFile: path];
    
    // 配置错误
    if (!_configureFileRootDictionary) {
        return [HXBaseError errorWithcode: kBaseErrorTypeWorkingManagerConfigError info: @"配置文件错误"];
    }
    
    
    // 控制器 key
    NSString *controllerKey = [_configureFileRootDictionary valueForKeyPath:base_working_manager_service_controller];
    
    // 开始工作
    self->_controller = [[NSClassFromString(controllerKey) alloc] init];
    [self->_controller startWork];
    
    if (self->_controller) {
        _isConfigWorkingManager = YES;
    } else {
        return [HXBaseError errorWithcode:kBaseErrorTypeWorkingManagerConfigError info: @"配置文件中的控制器不存在"];
    }
    
    // 支持的协议
    _supportProtocol = [_configureFileRootDictionary valueForKeyPath: base_working_manager_support_protocol];
    
    if (!_supportProtocol) {
        return [HXBaseError errorWithcode:kBaseErrorTypeWorkingManagerConfigError info: @"配置文件中的协议不存在"];
    }
    
    return nil;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 默认未配置
        baseWorkingManager = [super allocWithZone:zone];
        baseWorkingManager->_isConfigWorkingManager = NO;
    });
    
    return baseWorkingManager;

}


- (void)get:(NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *, id))success failure:(void (^)(HXBaseAction *, HXBaseError *))failure {
    
    // 首先检查是否配置了管理器
    HXBaseError *error = [self checkConfig];
    if (error) {
        failure(nil, error);
        return;
    }
    // 然后检查 URLString
    
    
}

- (void)post:(NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *, id))success failure:(void (^)(HXBaseAction *, HXBaseError *))failure {
    
    HXBaseError *error = [self checkConfig];
    if (error) {
        failure(nil, error);
    }
    
    // 处理参数
    [self handleURLString: URLString parameters: parameters success: success failure: failure];
}

#pragma mark---检查配置
- (HXBaseError *) checkConfig {
    
    if (!self->_isConfigWorkingManager) {
        return [HXBaseError errorWithcode: kBaseErrorTypeWorkingManagerNotConfig info: @"没有为管理器加载配置文件"];
    }
    
    return nil;
}

#pragma mark---处理参数
- (void ) handleURLString: (NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *, id))success failure:(void (^)(HXBaseAction *, HXBaseError *))failure {
    
    
    NSMutableDictionary *allParameters = [NSMutableDictionary dictionaryWithCapacity: 4];
    
    HXBaseError *error = nil;
    
    NSParameterAssert(URLString);
    
    NSURL *URL = [NSURL URLWithString: URLString];
    
    // scheme 协议
    NSString *protocol = URL.scheme;
    
    if (protocol && [protocol isEqualToString: _supportProtocol]) {
        NSLog(@"协议合法");
    } else {
        HXBaseError *error = [HXBaseError errorWithcode: kBaseErrorTypeUnSupportedProtocol info: @"暂不支持的协议"];
        failure(nil, error);
    }
    
    // host
    NSString *host = URL.host;
    NSParameterAssert(host);
    
    // 路径
    NSString *path = URL.path;
    NSParameterAssert(path);
    
    // 参数
    NSString *param = URL.query;
    if (param) {
        
        // 获取参数
        NSArray *paramArray = [param componentsSeparatedByString: @"&"];
        for (NSString *param in paramArray) {
            NSArray *keyValues = [param componentsSeparatedByString: @"="];
            
            if (keyValues.count != 2) {
                error = [HXBaseError errorWithcode: kBaseErrorTypeUnSupportedAction info: @"参数错误"];
                failure(nil, error);
                return;
            }
            [allParameters setObject: keyValues[1] forKey: keyValues[0]];
        }
    }
    
    // keyPath 查询 action
    NSString *keyPath = [NSString stringWithFormat: @"%@%@", host, [path stringByReplacingOccurrencesOfString: @"/" withString: @"."]];
    NSString *workingAction = [_configureFileRootDictionary valueForKeyPath: keyPath];
    
    // 支持 NSDictionary 
    if (parameters && [parameters isKindOfClass: [NSDictionary class]]) {
        // 添加参数
        [allParameters addEntriesFromDictionary: parameters];
    }
    
    if (workingAction) {
        // 异步调用
       
        dispatch_async(dispatch_get_main_queue(), ^{
            // 处理参数和回调数据
            [self->_controller sendAction: workingAction parameters: allParameters success: success failure: failure];
        });
    } else {
        error = [HXBaseError errorWithcode: kBaseErrorTypeUnSupportedAction info: @"URL 不合法或暂不支持的接口"];
        
        failure(nil, error);
    }
    
}

@end
