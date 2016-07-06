//
//  HXBaseWorkingManager.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/19.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HXBaseController, HXBaseAction, HXBaseError;

/**
 *  @author huangxiong, 2016/04/06 17:07:46
 *
 *  @brief 支持的协议, 作为 keyPath
 *
 *  @since 1.0
 */
static NSString *base_working_manager_support_protocol = @"protocols.support_protocol";

/**
 *  @author huangxiong, 2016/04/06 17:07:23
 *
 *  @brief 控制器组
 *
 *  @since 1.0
 */
static NSString *base_working_manager_controllers = @"controllers";

/**
 *  @author huangxiong, 2016/04/06 17:06:55
 *
 *  @brief 提供服务的控制器, 作为 keyPath
 *
 *  @since 1.0
 */
static NSString *base_working_manager_service_controller = @"controllers.service_controller";

@interface HXBaseWorkingManager : NSObject

/**
 *  @brief  管理器单例
 *  @param  void
 *  @return 管理器实例
 */
+ (instancetype) manager;

/**
 *  @brief  通过配置文件, 配置管理器
 *  @param  fileName 是文件名, 格式要求是 plist 文件, 文件格式是 NSDictionary 字典, 里面分 actions,
 *          controllers, devices, clients几大类, 其中 actions 即是 HXBaseAction 及其子类字典集合;
 *          controllers 是  HXBaseController 或者其子类名, 必须有;
 *          devices 是 HXBaseDevice 及其子类名构成的字典集合;
 *          clients 是 HXBaseClient 及其子类名构成的字典集合;
 *          controllers 需要指定服务的 controller
 *
 *  @return workingManager 实例
 */
+ (instancetype) managerWithConfiguresOfFile: (NSString *)fileName;


/**
 *  @author huangxiong, 2016/04/06 10:29:58
 *
 *  @brief 加载配置文件, 配置文件中包含了提供操作服务的控制器, 以及支持的操作服务类型
 *
 *  @param fileName 是配置文件
 *
 *  @return 返回 nil 表示配置成功, 其他表示错误
 *
 *  @since 1.0
 */
- (HXBaseError *) setConfiguresOfFile: (NSString *)fileName;

/**
 *  get
 */
- (void) get:(NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *action, id responseObject))success failure:(void (^)(HXBaseAction *action, HXBaseError *error))failure;

/**
 *  post 方法
 */
/**
 *  @author huangxiong, 2016/04/06 15:52:43
 *
 *  @brief post 方法提交请求
 *
 *  @param URLString  这个是 URL 地址
 *  @param parameters 参数, 支持 NSDictionary, NSString, NSData 三种类型
 *  @param success    成功回调
 *  @param failure    失败回调
 *
 *  @since 1.0
 */
- (void) post:(NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *action, id responseObject))success failure:(void (^)(HXBaseAction *action, HXBaseError *error))failure;

@end
