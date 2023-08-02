
import UIKit
import AVFoundation

class AVPlayerViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var songImageView: UIImageView!
    var isPlaying = false
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardSkip: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var Backward: UIButton!
    @IBOutlet weak var backwardSkip: UIButton!
    @IBOutlet weak var currentTimeInterval: UILabel!
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var timer: Timer?
    var currentIndex = 0
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var itemDuration: UILabel!
    var song = ["http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Sevish_-__nbsp_.mp3","http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        avplayerUrl()
        slider.minimumValue = 0
        slider.value = 0
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(forTimer), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    @objc func forTimer(){
        let currentTime : CMTime = (self.playerItem?.currentTime())!
        let seconds : Float64 = CMTimeGetSeconds(currentTime)
        let time : Float = Float(seconds)
        self.slider.value = time - 1
        
        let times  = Int(time)
        let runTime = timeFormatted(totalSeconds: times)
        currentTimeInterval.text = runTime
        
    }
    @IBAction func forwardSkip(_ sender: Any) {
        
        let moveForword : Float64 = 10
        if player == nil { return }
        if let duration  = player!.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
            let newTime = playerCurrentTime + moveForword
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player!.seek(to: selectedTime)
                
            }
            player?.pause()
            
        }
        if isPlaying {
            player?.play()
        } else {
            player.pause()
        }
        
    }
    @IBAction func backwardSkip(_ sender: Any) {
        
        let moveBackword: Float64 = 10
        if player == nil
        {
            return
        }
        let playerCurrenTime = CMTimeGetSeconds(player!.currentTime())
        var newTime = playerCurrenTime - moveBackword
        if newTime < 0
        {
            newTime = 0
        }
        player?.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: selectedTime)
        //   playerCurrenTime = Float64(slider.value)
        
        if isPlaying {
            player?.play()
        } else {
            player.pause()
        }
        
        
    }
    @IBAction func backWard(_ sender: Any) {
        if currentIndex > 0 {
            currentIndex -= 1
            avplayerUrl()
            if isPlaying {
                player.play()
            }
        }
    }
    @IBAction func Forward(_ sender: Any) {
        if currentIndex < song.count - 1 {
            currentIndex += 1
            avplayerUrl()
            if isPlaying{
                player.play()
            }
        }
        
    }
    @IBAction func playPause(_ sender: Any) {
        if isPlaying {
            slider.isContinuous = true
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)

            player?.pause()
            
            print("ok")
        } else {
            
            avplayerUrl()
            
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            let seconds : Int64 = Int64(slider.value)
            let preferredTimeScale : Int32 = 1
            let seekTime : CMTime = CMTimeMake(value: seconds, timescale: preferredTimeScale)
            playerItem.seek(to: seekTime, completionHandler: nil)
            player?.play()
            print("done")
            
        }
        isPlaying = !isPlaying
        
        
    }
    
    @IBAction func forSlider(_ sender: UISlider) {
           slider.isContinuous = true
        if self.slider.isTouchInside {
//            player?.pause()
            let seconds : Int64 = Int64(slider.value)
            let preferredTimeScale : Int32 = 1
            let seekTime : CMTime = CMTimeMake(value: seconds, timescale: preferredTimeScale)
            playerItem?.seek(to: seekTime, completionHandler: nil)
            if isPlaying{
             //   player.pause()
              //  slider.isContinuous = true
                player?.play()
            } else {
                player.pause()
              
            }
            
            
        } else {
            
            let duration : CMTime = (self.player?.currentItem!.asset.duration)!
            let seconds : Float64 = CMTimeGetSeconds(duration)
            self.slider.value = Float(seconds)
            
            
        }
        
        
        
    }
    
    func avplayerUrl(){
        guard let songUrl = URL(string: song[currentIndex] ) else {
            return
        }
        playerItem = AVPlayerItem(url: songUrl)
        player = AVPlayer(playerItem: playerItem)
        
        let duration : CMTime = (self.player?.currentItem!.asset.duration)!
        let seconds : Float64 = CMTimeGetSeconds(duration)
        let maxTime : Float = Float(seconds)
        self.slider.maximumValue = maxTime
        
        let times  = Int(maxTime)
        let durationTime = timeFormatted(totalSeconds: times)
        itemDuration.text = durationTime
        extractImageFromMP3(fileURL: songUrl)
        //        if let songImages = extractImageFromMP3(fileURL: songUrl) {
        //            songImageView.image = songImages
        //        } else {
        //            songImageView.image = UIImage(systemName: "person.fill")
        //        }
        
        
    }
    func extractImageFromMP3(fileURL: URL) {
        let asset = AVAsset(url: fileURL)
        
        // Get the metadata for the asset
        let metadata = asset.metadata(forFormat: AVMetadataFormat.id3Metadata)
        
        // Filter the metadata to find the image data
        let imageMetadata = metadata.filter { item in
            return item.commonKey == AVMetadataKey.commonKeyArtwork
        }
        
        // Extract the image data from the metadata
        if let imageData = imageMetadata.first?.value as? Data,
           let image = UIImage(data: imageData) {
            songImageView.image = image
        }
        if let title = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierTitle).first?.stringValue {
            titleLabel.text = "song title: \(title)"
        }
        
        // Extract and display the author name
        if let author = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierArtist).first?.stringValue {
            authorLabel.text = "Author name: \(author)"
        }
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //       let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d min", minutes, seconds)
    }
    
}




