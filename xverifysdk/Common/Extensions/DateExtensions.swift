//
//  DateExtensions.swift
//  xverifysdk
//
//  Created by Minh Tri on 17/12/2023.
//


extension Date {
    public var millisecondsSince1970:Int64 {
        return Int64((timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
