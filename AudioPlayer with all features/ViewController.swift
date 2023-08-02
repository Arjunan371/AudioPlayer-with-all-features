//
//  ViewController.swift
//  AudioPlayer with all features
//
//  Created by Mohammed Abdullah on 26/07/23.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var skipForward: UIButton!
    @IBOutlet weak var skipBackward: UIButton!
    @IBOutlet weak var backward: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var sonImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        player?.delegate = self
        forwardButton.setTitle("", for: .normal)
        //backward.setTitle("", for: .normal)
        skipForward.setTitle("", for: .normal)
        //skipBackward.setTitle("", for: .normal)
        playPauseButton.setTitle("", for: .normal)
        setupAudioPlayer()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
        
    }
    var player: AVAudioPlayer!
    var isPlaying = false
    var currentSongIndex = 0
    let songs = ["Kaavaalaa-MassTamilan.dev","Hukum---Thalaivar-Alappara-MassTamilan.dev"] // Add the names of your songs here
    
    func setupAudioPlayer() {
        guard let songURL = Bundle.main.url(forResource: songs[currentSongIndex], withExtension: "mp3") else {
            print("Song not found.")
            
            return
        }
        if let songImage = extractImageFromMP3(fileURL: songURL) {
            sonImageView.image = songImage
        } else {
            // Set the default image if no image found in metadata
            sonImageView.image = UIImage(named: "default_audio_image")
        }
        
        player = try! AVAudioPlayer(contentsOf: songURL)
    }
    func updateSliders() {
        slider.value = Float(player.currentTime)
    }
    @IBAction func goForward(_ sender: Any) {
        let currentTime = player.currentTime + 10.0
        if currentTime < player.duration {
            player.currentTime = currentTime
            updateSliders()
        }
    }
    @IBAction func goBackward(_ sender: Any) {
        let currentTime = player.currentTime - 10.0
        if currentTime < player.duration {
            player.currentTime = currentTime
            updateSliders()
        }
    }
    
    func updateUI() {
        
        if isPlaying {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            slider.maximumValue = Float(player.duration)
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            slider.maximumValue = Float(player.duration)
        }
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if isPlaying {
            player.pause()
            
        } else {
            player.play()
            
        }
        isPlaying = !isPlaying
        updateUI()
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if currentSongIndex < songs.count - 1 {
            currentSongIndex += 1
            setupAudioPlayer()
            if isPlaying {
                player.play()
            }
            updateUI()
        }
    }
    
    @IBAction func previousButtonTapped(_ sender: UIButton) {
        if currentSongIndex > 0 {
            currentSongIndex -= 1
            setupAudioPlayer()
            if isPlaying {
                player.play()
            }
            updateUI()
        }
    }
    @objc func updateSlider(){
        slider.value = Float(player.currentTime )
    }
    
    @IBAction func sliderAction(_ sender: Any) {
        player.stop()
        player.currentTime = TimeInterval(slider.value)
        player.prepareToPlay()
        player.play()
    }
    
    func extractImageFromMP3(fileURL: URL) -> UIImage? {
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
            return image
        }
        
        return nil
    }
    
    
}

