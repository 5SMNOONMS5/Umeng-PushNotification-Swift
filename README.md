# Umeng-PushNotification-Swift
實作友盟推播 ( iOS 8 以上 )


# 一：註冊友盟帳號

註冊[友盟](http://dev.umeng.com/push/ios/integration)帳號 

並且上傳正確的開發以及發布證書

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/0.png)

# 二：安裝 SDK 到專案

首先下載 [v1.5.0a版本(支援到 iOS 10)](http://dev.umeng.com/push/ios/integration)

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/1.png)

Import UMessage.h 到 Bridging-Header.h 

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/2.png)

打開推播通知

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/3.png)


# 三：複製貼上 （記得要改Appkey）

我將 Code 分為三大部分，如果當前專案只支援到 iOS 9，那就複製 **第1** 跟 **第2**，如果是從 iOS 8 開始支援，那就全部都複製。

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/4.png)

# 四：把 DeviceToken 貼到官網上，然後完畢。

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/5.png)

# 五：進階版本的 Interactive Notification (可互動的推播)

這邊我把 Code 分成 **iOS 10 以上** 以及 **iOS 10 以下** 兩個方法

```swift
self.setupiOS10AndAboveCategory(center: center)

self.setupiOS8AndiOS9ActionCategory()
```

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/6.png)

iOS 10 以上 

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/7.png)

iOS 8 ~ iOS 9

![](https://github.com/5SMNOONMS5/CLS-Umeng-PushNotification-Swift/blob/master/images/8.png)



