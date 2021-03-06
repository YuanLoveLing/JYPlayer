//
//  JYMusicPlayerManager.swift
//  JYMusicPlayer
//
//  Created by 靳志远 on 2017/5/10.
//  Copyright © 2017年 靳志远. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - JYPlayer
class JYMusicPlayerManager: NSObject {
    /// 记录当前音乐链接
    fileprivate var currentURLString: String?
    fileprivate var player: AVPlayer?
    fileprivate var playerItem: AVPlayerItem?
    /// 记录是否正在播放
    var isPlaying: Bool = false
    
    /// 实例化对象单例方法
    static let shareInstance: JYMusicPlayerManager = {
        return JYMusicPlayerManager()
    }()
    
    override init() {
        // 设置支持后台播放
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            
        }catch {
            
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            
        }catch {
            
        }
    }
    
    /**
     播放
     urlString: 音乐链接
     isOnline: 是否是线上播放
     */
    func play(urlString: String, isOnline: Bool) -> (AVPlayerItem?) {
        // 先看缓存池中是否有player
        player = playerDictionary[urlString]
        if player != nil {// 缓存池中有
            
        }else {// 缓存池中没有
            var url: URL?
            // 注意：在线播放和本地播放的主要区别就是创建URL的方法不同
            if isOnline == true {// 在线播放
                url = URL(string: urlString)
                
            }else {// 本地播放
                url = URL(fileURLWithPath: urlString)
                
            }
            
            guard let myURL = url else {
                return nil
            }
            playerItem = AVPlayerItem(url: myURL)
            player = AVPlayer(playerItem: playerItem)
            
            let versionStr = NSString(string: UIDevice.current.systemVersion)
            if versionStr.integerValue >= 10 {
                /*
                 ios10种AVPlayer增加了多个属性，其中有几个需要注意一下
                 timeControlStatus
                 automaticallyWaitsToMinimizeStalling: 自动等待以减少拖延
                 */
                // 设置为非自动等待，以避免在线播放时缓冲时间过长
                player?.automaticallyWaitsToMinimizeStalling = false
            }
            
            // 将新创建的playerItem放入缓存池中
            playerDictionary[urlString] = player
        }
        // 播放
        player?.play()
        isPlaying = true
        
        // 记录当前音乐链接
        currentURLString = urlString
        return playerItem
    }
    
    /// 暂停
    func pause() -> () {
        guard let player = player else {
            return
        }
        
        player.pause()
        isPlaying = false
    }
    
    /// 销毁
    func destroy() -> () {
        player?.pause()
        player = nil
        playerItem = nil
        playerDictionary.removeValue(forKey: currentURLString ?? "")
    }
    
    // MARK: - lazy
    fileprivate lazy var playerDictionary: [String: AVPlayer] = {
        return [String: AVPlayer]()
    }()
}
