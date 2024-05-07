//
//  EkycLivenessProtocol.swift
//  xverifysdk
//
//  Created by Minh Tri on 17/12/2023.
//

@objc public protocol EkycLivenessDelegate {
    @objc optional func onStepLeft()
    @objc optional func onStepCenter()
    @objc optional func onStepRight()
    @objc optional func onStepSmile()
    @objc optional func onMultiFace()
    @objc optional func onNoFace()
    @objc optional func onPlaySound()
}
