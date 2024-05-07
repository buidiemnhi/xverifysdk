//
//  ModelProtocol.swift
//  eidos
//
//  Created by Tony Kieu on 25/08/2023.
//

import ObjectMapper

@objc public protocol ModelProtocol {
    @objc optional var searchCriteria: String { get }
    @objc optional var statusMessage: String? { get }
    @objc func isValid() -> Bool
}

@objc public protocol AutoHashable {
}

let IntTransform = TransformOf<Int, String>(fromJSON: { (value: String?) -> Int? in
    return Int(value!)
}, toJSON: { (value: Int?) -> String? in
    if let value = value {
        return String(value)
    }
    return nil
})

let BoolTransform = TransformOf<Bool, String>(fromJSON: { (value: String?) -> Bool? in
    return Int(value!) == 0 ? false : true
}, toJSON: { (value: Bool?) -> String? in
    if let value = value {
        return String(value)
    }
    return nil
})
