//
//  NotificationViewController.swift
//  Notification
//
//  Created by StephenChen on 15/09/2017.
//  Copyright © 2017 StephenChen. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

final class NotificationService: UNNotificationServiceExtension {
    
    // MARK: - Constant Key, Mush exactly match the key on UMeng
    let ATTACHMENT_URL_KEY = "attachment-url"
    let APS = "aps"
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.title = "\(bestAttemptContent.title) [00000]"
            contentHandler(bestAttemptContent)
        }
        
        /// Exit while any progress goes wrong
        func failEarly() { contentHandler(request.content) }
        
        if let bestAttemptContent = bestAttemptContent {
            
            //            guard let attachmentURL = bestAttemptContent.userInfo[ATTACHMENT_URL_KEY] as? String else { return failEarly() }
            
            bestAttemptContent.title = "\(bestAttemptContent.title) [00000]"
            
            guard let imageURL = URL(string: "https://i.ytimg.com/vi/dfUIYlwLZ6c/hqdefault.jpg") else {
                bestAttemptContent.title = "\(bestAttemptContent.title) [AAAA]"
                return failEarly()
            }
            
            var imageData: Data?
            do {
                imageData = try Data(contentsOf: imageURL)
            } catch {
                bestAttemptContent.title = "\(bestAttemptContent.title) [EEEE]"
            }
            
            guard let data = imageData else {
                bestAttemptContent.title = "\(bestAttemptContent.title) [BBBB]"
                return failEarly()
            }
            
            guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "image.gif", data: data, options: nil) else {
                bestAttemptContent.title = "\(bestAttemptContent.title) [CCCC]"
                return failEarly()
            }
            
            bestAttemptContent.attachments = [attachment]
            bestAttemptContent.title = "\(bestAttemptContent.title) [DDDDD]"
            contentHandler(bestAttemptContent)
            
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension UNNotificationAttachment {
    
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: Data, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let aURL: URL =  tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            let imageAttachment = try UNNotificationAttachment(identifier: imageFileIdentifier, url: aURL, options: options)
            return imageAttachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}
