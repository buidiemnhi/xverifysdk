//
//  EkycVerificationMode.swift
//  xverifysdk
//
//  Created by Minh Tri on 17/12/2023.
//

public enum EkycVerificationMode {
    case liveness                       //Only face center
    case liveness_face_matching         //Live face & eidFace: verifyFaceMatch
    case verify_liveness                //Verify left - right - center: verifyLiveness
    case verify_liveness_face_matching  //(verify left - right - center) vs (live face & eidFace) : verifyFaceMatch
}
