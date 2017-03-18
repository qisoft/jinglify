//
// Created by Innokentiy Shushpanov on 18/03/2017.
// Copyright (c) 2017 Innokentiy Shushpanov. All rights reserved.
//

import Foundation
import MediaPlayer
import AVKit
import AVFoundation

class AudioPlayer {
    private var player : AVAudioPlayer?
    private var beepPlayer : AVAudioPlayer?
    private var shortBeepPlayer : AVAudioPlayer?
    private var fadingCurveIdx = 0
    private var isFading = false

    private var beepTimer: Timer?
    private var playerTimer: Timer?

    init(withSong song: MPMediaItem) {
        changeSong(song: song)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch{ }
        beepPlayer = getAudioPlayer(forFile: "beep-01a", withExtension: "wav")
        shortBeepPlayer = getAudioPlayer(forFile: "beep-02", withExtension: "wav")
    }

    deinit {
        stopPlayers()
    }

    func vibrate(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    func changeSong(song: MPMediaItem) {
        if let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
            do {
                player = try AVAudioPlayer(contentsOf: url)
            } catch { }
        }
    }

    func pauseJingle(){
        player?.pause()
        if isFading {
            self.playerTimer?.invalidate()
            self.playerTimer = nil
        }
    }

    private func enqueue() {
    }

    private func getAudioPlayer(forFile : String, withExtension : String) -> AVAudioPlayer?{
        if let url = Bundle.main.url(forResource: forFile, withExtension: withExtension){
            do {
                return try AVAudioPlayer(contentsOf: url)
            } catch { }
        }
        return nil
    }

    func playJingle(){
        player?.play()
        if isFading {
            self.setupFadingTimer()
        }
    }

    func longBeep(){
        beepPlayer?.play()
    }

    func beep(times: Int){
        var beepsLeft = times
        beepTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { (timer) in
            beepsLeft = beepsLeft - 1
            self.shortBeepPlayer?.play()
            if(beepsLeft == 0){
                self.beepTimer?.invalidate()
                self.beepTimer = nil
            }
        }
    }

    func stopPlayers(){
        beepTimer?.invalidate()
        beepTimer = nil
        player?.stop()
        playerTimer?.invalidate()
        playerTimer = nil
    }

    private func setVolume(to value: Float){
        player?.setVolume(value, fadeDuration: 0.1)
        print("new volume is \(value)")
    }

    let volumeCurve : [Float] = [
        1.0,
        0.8,
        0.6,
        0.4,
        0.2,
        0.1,
        0.08,
        0.06,
        0.04,
        0.02,
        0.01,
        0.008,
        0.006,
        0.004,
        0.002,
        0.001,
        0.0006,
        0.0003,
        0
    ]
    
    func fadeOutAndStopPlayer(){
        self.fadingCurveIdx = 0
        self.setupFadingTimer()
        self.isFading = true
    }

    private func setupFadingTimer(){
        if let timer = self.playerTimer {
            timer.invalidate()
        }

        playerTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { (timer) in
            let volume = self.volumeCurve[self.fadingCurveIdx]
            self.fadingCurveIdx += 1
            self.setVolume(to: volume)
            if(volume == 0){
                self.player?.stop()
                self.player?.currentTime = 0
                self.setVolume(to: 1.0)
                self.isFading = false
                self.playerTimer?.invalidate()
                self.playerTimer = nil
            }
        })
    }
}
