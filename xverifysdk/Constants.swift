//
//  Constants.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import UIKit

// --------------------------------------
// MARK: Date Format
// --------------------------------------

public let kFormatDate: String = "yyyy-MM-dd 00:00:00"
public let kFormatDateShort: String = "yyyy-MM-dd"
public let kFormatDateTime: String = "yyyy-MM-dd HH:mm:00.000"
public let kFormatDateTimeShort: String = "yyyy-MM-dd HH:mm:ss"
public let kFormatDateTimeLong: String = "yyyy-MM-dd HH:mm:ss.SSS"
public let kFormatUSDateTime24: String = "MM/dd/yyy HH:mm"
public let kFormatUSDateTime24Short: String = "M/dd/yy HH:mm"
public let kFormatUSDateTimeAMPM: String = "MM/dd/yyy hh:mm a"
public let kFormatUSDateTimeAMPMYearFirst: String = "yyyy-MM-dd hh:mm a"
public let kFormatUSDateTimeAMPMYearFirstGMT: String = "yyyy-MM-dd hh:mm aZ"
public let kFormatDateUTC: String = "yyyy-MM-dd HH:mm:ss ZZZ"
public let kFormatDateISO8601Short: String = "yyyy-MM-dd'T'HH:mm:ss"
public let kFormatDateISO8601: String = "yyyy-MM-dd'T'HH:mm:ss.SSS"
public let kFormatDateISO8601UTC: String = "yyyy-MM-dd'T'HH:mm:ssZ"
public let kFormatDateISO8601UTCTime0: String = "yyyy-MM-dd'T'HH:mm:ss+0000"
public let kFormatDateISO8601UTCStartDate: String = "yyyy-MM-dd'T'00:00:00Z"
public let kFormatDateISO8601UTCSEndDate: String = "yyyy-MM-dd'T'23:59:59Z"
public let kFormatDateGMT: String = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
public let kFormatDayOfWeekWithDate: String = "EEE, dd MMM"
public let kFormatDayOfWeekLongWithDate: String = "EEEE, dd MMMM"
public let kFormatDayMonthDate: String = "dd MMM"
public let kFormatDayOfWeekWithDateTime: String = "EEE, dd MMM - hh:mm a"
public let kFormatDayMonthShort: String = "MMM/dd"
public let kFormatMonthYearShort: String = "MMM, yyyy"
public let kFormatMonthYearLong: String = "MMMM yyyy"
public let kFormatDateOnly: String = "dd"
public let kFormatDayOfWeekShort: String = "EEE"
public let kFormatDayOfWeekLong: String = "EEEE"
public let k24FormatTimeHourMinute: String = "HH:mm"
public let k24FormatTimeHourMinuteSecond: String = "HH:mm:ss"
public let k12FormatTimeHourMinute: String = "hh:mm a"
public let kFormatMinuteSecond: String = "mm:ss"
public let kFormatDateUS: String = "MM/dd/yyyy"
public let kFormatDateUSShort: String = "M/dd/yy"
public let kFormatDateId: String = "MMddyyyy"
public let kFormatUrlParamDate: String = "yyyyMMdd"
public let kFormatDateRecordISO: String = "yyyyMMddTHHmmssZ"
public let kFormatDatePlayback: String = "yyyy/MM/dd HH:mm:ss"
public let kFormatDatePlaybackWithTimeZone: String = "yyyy/MM/dd HH:mm:ssZ"
public let kFormatDatePasscode = "MMM d yyyy"
public let kFormatDateJobSection = "d MMM yyyy"
public let kFormatDateVI = "dd/MM/yyyy"
public let kFormatUSTimeHourAMPM: String = "yyyy-dd-MM hh a"
public let kFormatDateEventRecord: String = "yyyyMMddHHmmss"
public let kFormatUSDateTimeSecondAMPM: String = "MM/dd/yyy hh:mm:ss a"
public let kFormatVIDateTimeSecondAMPM: String = "dd/MM/yyy hh:mm:ss a"
public let kFormatDateVideoName: String = "yyyyMMddHHmmss"
public let kFormatDateInterviewSummary = "d MMM yyyy hh:mm a"

// --------------------------------------
// MARK: Common Macros
// --------------------------------------

public var SDKBUNDLE: Bundle {
    return Bundle(identifier: "vn.jth.xverifysdk") ?? Bundle.main
}

public var HOMEDIRECTORY: String {
    return ProcessInfo.processInfo.environment["HOME"] ?? ""
}

public func LOCALIZED(_ key: String) -> String {
    return NSLocalizedString(key, bundle: Bundle.main, comment: "")
}

public func INIT_CONTROLLER_XIB<T: UIViewController>(_ clazz: T.Type) -> T {
    print(clazz)
    return T(nibName: String(describing: clazz), bundle: nil)
}

public func DISPATCH_ASYNC_MAIN_AFTER(_ delay: Double, closure: @escaping () -> Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

public func DISPATCH_ASYNC_MAIN(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

public func DISPATCH_ASYNC_BG(_ closure: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async(execute: closure)
}

public func DISPATCH_ASYNC_BG_AFTER(_ delay: Double, _ closure: @escaping () -> Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.global(qos: .background).asyncAfter(deadline: when, execute: closure)
}
