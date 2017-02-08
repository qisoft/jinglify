//
//  ViewController.swift
//  jinglify
//
//  Created by Innokentiy Shushpanov on 01/02/2017.
//  Copyright © 2017 Innokentiy Shushpanov. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVKit

class ViewController: UIViewController {
    // MARK: - Reference outlets
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var timeLeftLabel: UILabel!

    // MARK: - Fields
    var player : MPMusicPlayerController?
    var beepPlayer : AVAudioPlayer?
    var shortBeepPlayer : AVAudioPlayer?
    var masterVolumeSlider = MPVolumeView()
    var matchTimeLeft: Double = 0.0
    var totalMatchTime: Double = 0.0
    var beepTime = 0
    var isGameStarted = false
    var initialVolume : Float = 0.0
    var isJinglePlaying : Bool = false
    var isThrowing : Bool = false

    var gameSettings = GameSettings()
    
    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        player = MPMusicPlayerController.applicationMusicPlayer()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch{ }
        beepPlayer = getAudioPlayer(forFile: "beep-01a", withExtension: "wav")
        shortBeepPlayer = getAudioPlayer(forFile: "beep-02", withExtension: "wav")
        gameView.isHidden = true

        masterVolumeSlider.alpha = 0.01
        self.view.addSubview(masterVolumeSlider)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startGame()
    }
    
    // MARK: - Event handlers
    @IBAction func onThrowTap(_ sender: Any) {
        if self.isJinglePlaying {
            player?.pause()
        }
        isThrowing = true
        Timer.scheduledTimer(withTimeInterval: TimeInterval(getRandomBeepTime()), repeats: false) { (timer) in
            if !self.isGameStarted {
                return
            }
            
            self.beepPlayer?.play()
            if self.isJinglePlaying {
                self.player?.play()
            }
            self.isThrowing = false
        }
    }
    
    @IBAction func onStopGameTap(_ sender: Any) {
        stopGame()
    }
    
    //MARK: - Game methods
    func startGame(){
        enqueSongs()
        gameView.isHidden = false
        beepTime = getRandomBeepTime()
        totalMatchTime = gameSettings.matchTime * 60 + 30 + Double(beepTime)
        matchTimeLeft = totalMatchTime
        isGameStarted = true
        self.update(timeLeft: totalMatchTime, timeSpent: 0)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if(!self.isGameStarted){
                timer.invalidate()
                return
            }
            
            if !self.isThrowing {
                self.matchTimeLeft = self.matchTimeLeft - 1
            }
            
            self.update(timeLeft: self.matchTimeLeft, timeSpent: self.totalMatchTime - self.matchTimeLeft)
        }
        
    }

    func enqueSongs() {
        player?.setQueue(with: gameSettings.songs)
        player?.nowPlayingItem = gameSettings.songs.items.first
        player?.prepareToPlay()
    }

    func stopGame(){
        gameView.isHidden = true
        isGameStarted = false
        player?.stop()
        dismiss(animated: true, completion: nil)
    }
    
    func update(timeLeft: Double, timeSpent: Double){
        print("time spent: \(timeSpent), time left: \(timeLeft)")
        switch timeSpent {
        case 0: playJingle()
        case 22: fadeOutAndStopPlayer()
        case 30+Double(beepTime): beepPlayer?.play()
        default: break
        }

        switch timeLeft {
        case 0:
            beepPlayer?.play()
            stopGame()
        case 7: fadeOutAndStopPlayer()
        case 30: playJingle()
        case 59..<gameSettings.matchTime * 60:
            if timeLeft.truncatingRemainder(dividingBy: 60.0) == 0 {
                beep(times: Int(timeLeft.divided(by: 60)))
            }
        default: break
        }
        
        if isThrowing {
            timeLeftLabel.text = "Get Ready!"
        }
        else if(timeLeft <= gameSettings.matchTime * 60){
            timeLeftLabel.text = stringFromTimeInterval(interval: timeLeft)
        }
        else if (timeSpent <= 30){
            timeLeftLabel.text = "Warm-up!"
        }
        else{
            timeLeftLabel.text = "Get Ready!"
        }
    }
    
    // MARK: - Audio player utils
    
    func getAudioPlayer(forFile : String, withExtension : String) -> AVAudioPlayer?{
        if let url = Bundle.main.url(forResource: forFile, withExtension: withExtension){
            do {
                return try AVAudioPlayer(contentsOf: url)
            } catch { }
        }
        return nil
    }
    
    func playJingle(){
        player?.play()
        isJinglePlaying = true
    }
    
    func stopJingle(){
        player?.stop()
        isJinglePlaying = false
    }
    
    func beep(times: Int){
        var beepsLeft = times
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { (timer) in
            if !self.isGameStarted {
                timer.invalidate()
                return
            }
            beepsLeft = beepsLeft - 1
            self.shortBeepPlayer?.play()
            if(beepsLeft == 0){
                timer.invalidate()
            }
        }
    }
    
    func fadeOutAndStopPlayer(){
        if let view = self.masterVolumeSlider.subviews.last as? UISlider{
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
                if !self.isGameStarted {
                    timer.invalidate()
                    return
                }
                if(self.initialVolume == 0){
                    self.initialVolume = view.value
                }
                view.value = view.value - self.initialVolume.divided(by: 10)
                print(view.value)
                view.sendActions(for: UIControlEvents.touchUpInside)
                if(view.value == 0){
                    self.player?.stop()
                    self.isJinglePlaying = false
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                        view.value = self.initialVolume
                        self.initialVolume = 0
                    })
                    timer.invalidate()
                }
            })
        }
    }
    
    // MARK: - Random utils
    func getRandomBeepTime() -> Int {
        let random = arc4random_uniform(2) + 2
        return Int(random)
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

