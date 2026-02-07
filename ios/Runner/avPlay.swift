//
//  avPlay.swift
//  Runner
//
//  Created by jyw on 2024/6/5.
//

import Foundation
import AVFoundation
var audioPlayer: AVAudioPlayer!
//var audioSession: AVAudioSession!
public func av_play(type:Int32){
    var assetStr : String = "avPlay1"
    if(type==1){
        assetStr = "avPlay"
    }
    let audioFile = NSDataAsset(name: assetStr)!
    //let audioFileUrl = URL(fileURLWithPath: audioFilePath)
    do{
        //audioSession=AVAudioSession.sharedInstance();
        
        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [.mixWithOthers])
        try AVAudioSession.sharedInstance().setActive(true)
        audioPlayer=try AVAudioPlayer(data: audioFile.data)
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
    catch{
    }
}
public func av_stop(){
    if audioPlayer == nil{
        return
    }
    audioPlayer.stop()
    // 恢复 AVAudioSession 为 playAndRecord，避免 .playback 与 WebRTC voice processing 冲突
    do {
        try AVAudioSession.sharedInstance().setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetooth]
        )
    } catch {
        // 恢复失败不影响主流程
    }
}
