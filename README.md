# Umeng-PushNotification-Swift
友盟推播 ( iOS 8 以上 )

# 分成兩階段
* 1. 友盟官方設定
* 2. 實作

## 前言： 

* 註冊[友盟](https://passport.umeng.com/signup?lang=zh_CN)帳號吧～

## 1-1:  友盟官方設定 - 創建新應用

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/0.png)

## 1-2:  友盟官方設定 - 上傳正確的開發證書以及申請憑證

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/1.png)

憑證問題可以參考[這篇](https://www.appcoda.com.tw/push-notification-ios/)，圖文教學非常詳細。

# 2:  實作

# 2-1 : 實作 - 引入 SDK  

1. 手動
到[官網](https://developer.umeng.com/sdk/ios?refer=UPush)勾選並且下載。

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/2.png)

2. Cocoapod

```
pod 'UMCCommon'
pod 'UMCPush'
pod 'UMCSecurityPlugins'
```

更詳細的說明請看[官網圖文教學](https://developer.umeng.com/docs/66632/detail/66734)

# 2-1 : 實作 - 創建 config 檔案

寫出來的原因是之後假如要上架或者要修改一些專案的相關變數，可以很方便地在一個 file 裡面去修改就可以了。

```swift
public final class Config {
    
    static let share = Config()
    
    let keyUmeng: String = ""
    
    /// 上架記得改成 false
    let isEnableUmengLog: Bool = true
    
    let channelID: String = ""
}
```

# 2-2 : 實作 - 友盟初始化

```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.setupUmeng(launchOptions: launchOptions)
        
        return true
    }
```


```swift
func setupUmeng(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        /// 友盟初始化
        UMConfigure.initWithAppkey(Config.share.keyUmeng, channel: Config.share.channelID)
        UMConfigure.setLogEnabled(Config.share.isEnableUmengLog)
        
        /// 友盟統計
        MobClick.setScenarioType(eScenarioType.E_UM_NORMAL)
        
        /// iOS 10 以上必須支援
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        /// 友盟推送配置
        let entity = UMessageRegisterEntity.init()
        entity.types = Int(UMessageAuthorizationOptions.alert.rawValue) |
            Int(UMessageAuthorizationOptions.badge.rawValue) |
            Int(UMessageAuthorizationOptions.sound.rawValue)
        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (granted, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        UMessage.setAutoAlert(false)
    }
```

# 2-2 : 實作 - AppDelegate 推送方法

```swift
    /// 拿到 Device Token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        gc_HighLightPrint(msg: deviceToken.hexString)
    }
    
    /// 註冊推送失敗
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        gc_NegativePrint(msg: error.localizedDescription)
    }
    
    /// 接到推送訊息
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UMessage.didReceiveRemoteNotification(userInfo)
    }
```

# 2-3 : 實作 - 接收推送訊息 ( iOS 10 之前)

```swift 
    /// iOS10 以前接收的方法
    func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     for notification: UILocalNotification,
                     withResponseInfo responseInfo: [AnyHashable: Any],
                     completionHandler: @escaping () -> Void) {
        /// 这个方法用来做action点击的统计
        UMessage.sendClickReport(forRemoteNotification: responseInfo)
    }
```


# 2-4 : 實作 - 接收推送訊息 ( iOS 10 之後)

```swift 
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// iOS10 新增：當 App 在＊＊前景＊＊模式下
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo: [AnyHashable: Any] = notification.request.content.userInfo
        
        /// 處理遠程推送 ( Push Notification )
        if notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false {
            print("App 在＊＊前景＊＊模式下的遠程推送")
        } else {
            print("App 在＊＊前景＊＊模式下的本地推送")
        }
        completionHandler([.sound, .badge])
    }
    
    /// iOS10 新增：當 App 在＊＊背景＊＊模式下
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo
        
        (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false)
            /// 處理遠程推送 ( Push Notification )
            ? print("App 在＊＊背景＊＊模式下的遠程推送")
            /// 處理本地推送 ( Local Notification )
            : print("App 在＊＊背景＊＊模式下的本地推送")
    }
}
```














