//
//  AppDelegate.swift
//  CLSUmengPushNotification
//
//  Created by StephenChen on 08/09/2017.
//  Copyright © 2017 StephenChen. All rights reserved.
//

import UIKit

let ACTION_ACCEPT_ID = "actionAcceptID"
let ACTION_REJECT_ID = "actionRejectID"
let CATEGORY_ID = "categoryID"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.setupPushNotification(launchOptions: launchOptions)
    
        return true
    }
}

// ******************************************
//
// MARK: - 1.推播 iOS 8 ~ 10 基本設定
//
// ******************************************
extension AppDelegate {
    
    /// 推播的基本設定
    ///
    /// - Parameter launchOptions: <#launchOptions description#>
    fileprivate func setupPushNotification(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        /// 當 App 被 close 掉，然後這時候又有推播通知的話。
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] {
            print("有推播通知 \(userInfo)")
            return
        }
        
        UMessage.start(withAppkey: "App key", launchOptions: launchOptions)
        UMessage.registerForRemoteNotifications()
        
        /// iOS 10 以上，包含 iOS 10
        if #available(iOS 10, *) {
            
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let center = UNUserNotificationCenter.current()
            self.setupiOS10AndAboveCategory(center: center)
            center.delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
                
                if let error = error {
                    print("iOS 申請推播權限錯誤 \(error.localizedDescription)")
                    return
                }
                
                if granted {
                    print("點擊允許")
                } else {
                    print("點擊不允許")
                }
            })
        } else {
            self.setupiOS8AndiOS9ActionCategory()
        }
        
        /// 打开日志，方便调试
        UMessage.setLogEnabled(true)
        /// 关闭 U-Push 自带的弹出框
        UMessage.setAutoAlert(false)
    }
    
    /// 清除推播訊息
    fileprivate func cleanNotificationMessage() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            // To remove all pending notifications which are not delivered yet but scheduled.
            center.removeAllDeliveredNotifications()
            // To remove all delivered notifications
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }

    }
    
    /// 拿到 Device Token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("1.2.7版本开始不需要用户再手动注册devicetoken，SDK会自动注册 deviceToken = \(deviceToken.hexString)")
    }
    
    /// 獲取錯誤日誌
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("推播錯誤 \(error.localizedDescription)")
    }
}

// ******************************************
//
// MARK: - 2.推播 iOS 8 ~ 9 實作方法
//
// ******************************************
extension AppDelegate {

    /// iOS 8, 9 以下使用这个方法接收通知
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        /// 统计点击数
        UMessage.didReceiveRemoteNotification(userInfo)
        self.cleanNotificationMessage()
    }

    func setupiOS8AndiOS9ActionCategory() {
        
        let actionAccept = UIMutableUserNotificationAction()
        actionAccept.identifier = ACTION_ACCEPT_ID
        actionAccept.title = "接受"
        /// 當點擊印用，啟動 App
        actionAccept.activationMode = .foreground

        let actionReject = UIMutableUserNotificationAction()
        actionReject.identifier = ACTION_REJECT_ID
        actionReject.title = "拒絕"
        /// 当点击的时候不启动程序，在后台处理
        actionReject.activationMode = .background
        /// 需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        actionReject.isAuthenticationRequired = true
        actionReject.isDestructive = true

        let categorys = UIMutableUserNotificationCategory()
        /// 这组动作的唯一标示
        categorys.identifier = CATEGORY_ID
        categorys.setActions([actionAccept, actionReject], for: .default)
        UMessage.register(forRemoteNotifications: [categorys])
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        if identifier == ACTION_ACCEPT_ID {
            print("推播 ，點擊 接受")
        } else if identifier == ACTION_REJECT_ID {
            print("推播 ，點擊 拒絕")
        }
        self.cleanNotificationMessage()
    }
}

// ******************************************
//
// MARK: - 3.推播 iOS 10 以上實作方法
//
// ******************************************
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    fileprivate func setupiOS10AndAboveCategory(center: UNUserNotificationCenter) {
        
        let actionAccept = UNNotificationAction(identifier: ACTION_ACCEPT_ID, title: "接受", options: .foreground)
        let actionReject = UNNotificationAction(identifier: ACTION_REJECT_ID, title: "拒絕", options: .destructive)
        let category = UNNotificationCategory(identifier: CATEGORY_ID, actions: [actionAccept, actionReject], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
    
    /// iOS10 新增：當 App 在＊＊前景＊＊模式下會收到訊息
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        /// 推播的消息
        let userInfo: [AnyHashable: Any] = notification.request.content.userInfo
        print("推播的消息 = \(userInfo)")
        
        if notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false {
           print("當 App 在＊＊前景＊＊模式下，處理遠程推送")
        } else {
           print("當 App 在＊＊前景＊＊模式下，處理本地推送")
        }
        
        /// 统计点击数
        UMessage.didReceiveRemoteNotification(userInfo)
        
        completionHandler([.alert, .sound, .badge])
        self.cleanNotificationMessage()
    }
    
    /// iOS10 新增：當 App 在＊＊背景＊＊模式下
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        /// 推播的消息
        let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo
        print("推播的消息 = \(userInfo)")

        /// 统计点击数
        UMessage.didReceiveRemoteNotification(userInfo)
        
        if response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false {
            print("當 App 在＊＊背景＊＊模式下，處理遠程推送")
            if response.actionIdentifier == ACTION_ACCEPT_ID {
                print("推播，點擊 接受")
            } else if response.actionIdentifier == ACTION_REJECT_ID {
                print("推播，點擊 拒絕")
            }
        } else {
            print("當 App 在＊＊背景＊＊模式下，處理本地推送")
        }
    }    
}

// ******************************************
//
// MARK: - Helper (寫出來是因為之後可以給別的地方用)
//
// ******************************************
extension Data {
    
    /// Convert Data into String
    public var hexString: String {
        return withUnsafeBytes {(bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 })
        }
    }
}
