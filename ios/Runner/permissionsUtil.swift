//
//  permissionsUtil.swift
//  Runner
//
//  Created by jyw on 2024/6/5.
//

import Foundation
import AVFoundation
import Photos
// 相机权限
public func getCameraPermission()->String{
    let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    
    // .notDetermined  .authorized  .restricted  .denied
    if authStatus == .notDetermined {
        // 第一次触发授权 alert
        return "notDetermined"
    } else if authStatus == .authorized {
        return "authorized"
    } else {
        return "denied"
    }
}
//相册权限
public func getPhotoPermission()->String{
    let library:PHAuthorizationStatus=PHPhotoLibrary.authorizationStatus()
    
    // .notDetermined  .authorized  .restricted  .denied
    if library == .notDetermined {
        // 第一次触发授权 alert
        return "notDetermined"
    } else if library == .authorized {
        return "authorized"
    } else {
        return "denied"
    }
}
