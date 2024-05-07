//
//  EkycFaceResultProtocol.swift
//  xverifysdk
//
//  Created by Minh Tri on 17/12/2023.
//

import Foundation

public protocol EkycFaceResultDelegate {
    func onFaceLeft(_ faceLeft: String)
    func onFaceCenter(_ faceCenter: String)
    func onFaceRight(_ faceRight: String)
}
