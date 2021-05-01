//
//  musicViewController.swift
//  music
//
//  Created by yousun on 2021/4/23.
//

import UIKit
import AVFoundation // 音樂
import SpriteKit    // 粒子效果


// 創一個 musicArray 型別，用於加入歌曲
struct musicArray {
    let songName:String
    let songImage:String
    let music:String
}


let player = AVPlayer()
var playerItem : AVPlayerItem?
var emitterNode : SKEmitterNode?

var musicIndex = 0

var playArray : [ Int ] = []


    
let Array = [musicArray(songName: "Marshmello \n\n Here With Me", songImage: "Here With Me", music: "Marshmello - Here With Me"),musicArray(songName: "Ed Sheeran \n\n South of the Border", songImage: "south of border", music: "Ed Sheeran - South of the Border"),musicArray(songName: "Ed Sheeran \n\n Galway Girl", songImage: "galway girl", music: "Ed Sheeran - Galway Girl"),musicArray(songName: "Marshmello \n\n Happier", songImage: "Happier", music: "happier"),musicArray(songName: "Ed Sheeran \n\n Beautiful People", songImage: "Beautiful People", music: "beautiful people"),
]

class musicViewController: UIViewController {

    
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var nowtimeLabel: UILabel!
    @IBOutlet weak var totaltimeLabel: UILabel!
    
    @IBOutlet weak var musicplayButton: UIButton!
    @IBOutlet weak var musicSlider: UISlider!
    
    @IBOutlet weak var particleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nowMusic()
        
        currentTime()
        
        player.volume = 0.5
        
        endmusic()
        
        particle()
    }
    
    
    // 移動音樂時間的Slider
    @IBAction func musicChangeSlider(_ sender: UISlider) {
    
            let seconds = Int64(sender.value)
            let targetTime = CMTimeMake(value: seconds, timescale: 1)
            
            player.seek(to: targetTime)
    }
    
    
    // 播放、暫停
    @IBAction func playMusicBtn(_ sender: UIButton) {
        
        switch player.timeControlStatus {
        
        case .playing:
            musicplayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
            
        case .paused :
        musicplayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
            
        default:
            break
        }
    }
    
    
    // 下一首歌
    @IBAction func nextMusicBtn(_ sender: Any) {
    
        musicIndex += 1
        returnMusic()
        nowMusic()
    }
    
    
    // 上一首歌
    @IBAction func previousMusicBtn(_ sender: Any) {
        
        musicIndex -= 1
        returnMusic()
        nowMusic()
    }
    
    
    // 音量Slider
    @IBAction func volumeSlider(_ sender: UISlider) {
        
        player.volume = sender.value
    }
    
    
    // 設定背景粒子開關
    @IBAction func stopParticleBtn(_ sender: Any) {
        
        if emitterNode?.particleBirthRate == 0{
            
            emitterNode?.particleBirthRate = 80
            
            particleButton.tintColor = UIColor.systemOrange
            
        }else{
            emitterNode?.particleBirthRate = 0
            
            particleButton.tintColor = UIColor.systemGray
        }
    }
    
    
    // 把時間轉換成 0:00 模式
    func formatConversion(time:Double) -> String{
    
        let answer = Int(time).quotientAndRemainder(dividingBy: 60)
        let timestring = String(answer.quotient) + ":" + String(format: "%02d", answer.remainder)
        
        return timestring
    }
    
    
    // 抓取正在播放的歌曲，目前時間到哪
    func currentTime() {
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [self] (CMTime) in
            
            if player.currentItem?.status == .readyToPlay {
                
                let currentTime = CMTimeGetSeconds(player.currentTime())
                musicSlider.value = Float(currentTime)
                nowtimeLabel.text = formatConversion(time: currentTime)
            }
        })
    }
    
    
    // 播放歌曲，設定圖片、名稱
    func nowMusic() {
        
        for i in 0 ..< Array.count {
            playArray.append(i)
        }
        
        
        let fileUrl = Bundle.main.url(forResource: Array[playArray[musicIndex]].music, withExtension: "mp3")!
      
        let playerItem = AVPlayerItem(url: fileUrl)
        
        player.replaceCurrentItem(with: playerItem)
        
        musicImageView.image = UIImage(named: Array[playArray[musicIndex]].songImage)
        
        songNameLabel.text = Array[playArray[musicIndex]].songName
        
        
        // 每次轉換歌曲時，每首歌的秒數不同，設定歌曲的總時間
        let duration = playerItem.asset.duration
        
        let seconds = CMTimeGetSeconds(duration)
        
        musicSlider.maximumValue = Float(seconds)
        
        totaltimeLabel.text = formatConversion(time: Double(musicSlider.maximumValue))
        
        musicSlider.isContinuous = true
    }
    
    
    // 歌曲前後輪播
    func returnMusic() {
        
        if musicIndex == Array.count {
            
            musicIndex = 0
            
        }else if musicIndex == -1 {
            
            musicIndex = Array.count - 1
        }
    }

    
    // 偵測歌曲結束後從 0:00 開始
    func endmusic() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
            
            let targetTime = CMTimeMake(value: 0, timescale: 1)
            player.seek(to: targetTime)
    }
  }

    
    // 粒子大小、位置
    func particle(){
        
        let skView = SKView(frame: view.frame)
        view.insertSubview(skView, at: 0)
        
        let scene = SKScene(size: skView.frame.size)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.75)
        
        emitterNode = SKEmitterNode(fileNamed: "MybokehParticle")
        scene.addChild(emitterNode!)
        
        skView.presentScene(scene)
    }
}
