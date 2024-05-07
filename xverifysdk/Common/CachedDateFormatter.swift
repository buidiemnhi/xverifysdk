//
//  CachedDateFormatter.swift
//  xverifysdk
//
//  Created by Tony Kieu on 13/11/2023.
//

import UIKit

let DATEFORMATTER = CachedDateFormatter.shared

public class CachedDateFormatter: NSObject {
    
    private let kDateFormatterCacheLimit = 15
    private var _loadedDateFormatter: NSCache<AnyObject, AnyObject>!

    // --------------------------------------
    // MARK: Singleton
    // --------------------------------------

    class var shared: CachedDateFormatter {
        struct Static {
            static let instance = CachedDateFormatter()
        }
        return Static.instance
    }

    public override init() {
        super.init()
        _loadedDateFormatter = NSCache()
        _loadedDateFormatter.countLimit = kDateFormatterCacheLimit
    }

    // --------------------------------------
    // MARK: Singleton
    // --------------------------------------
    
    public func dateFormatterWith(format: String, locale: Locale, isTimeZoneFormat: Bool = true, timeZone: TimeZone? = TimeZone.current) -> DateFormatter {
        let key = String(format: "%@|%@", format, locale.identifier)
        var dateFormatter = _loadedDateFormatter.object(forKey: key as AnyObject) as? DateFormatter
        if dateFormatter == nil {
            dateFormatter = DateFormatter(withFormat: format, locale: locale.identifier)
            dateFormatter?.timeZone = isTimeZoneFormat ? timeZone : TimeZone.init(secondsFromGMT: 0)
            _loadedDateFormatter.setObject(dateFormatter!, forKey: key as AnyObject)
        }
        return dateFormatter!
    }

    public func dateFormatterWith(format: String, localeIdentifier: String) -> DateFormatter {
        dateFormatterWith(format: format, locale: Locale(identifier: localeIdentifier))
    }

    public func dateFormatterWith(format: String) -> DateFormatter {
        dateFormatterWith(format: format, locale: Locale.current)
    }

    public func getLocale () -> Locale {
        return  Locale.current
    }
}

