//
//  NotificationExtensions.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import UIKit

extension Notification.Name {
    static let didLogin = Notification.Name("notification_didlogin")
    static let didLogout = Notification.Name("notification_didlogout")
    static public let didUnAuthorized = Notification.Name("notification_didUnAuthorized")
    static let imageDidUpload = Notification.Name("notification_imagedidupload")
    static let latestMessageDidRefresh = Notification.Name("notification_latestmessagedidrefresh")
    static let didArm = Notification.Name("notification_didarm")
    static let pushNotification = Notification.Name("pushnotification")
    static let intercom = Notification.Name("intercom_notification")
    static let broadcasting = Notification.Name("broadcasting_notification")
    static let appDidBecomeActive = Notification.Name("app_become_active")
    static let appWillResignActive = Notification.Name("app_will_resign_active")
    static let deviceLock = Notification.Name("device_lock")
    static let deviceUnlock = Notification.Name("device_unlock")
}
