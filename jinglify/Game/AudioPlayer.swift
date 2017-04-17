//
// Created by Innokentiy Shushpanov on 18/03/2017.
// Copyright (c) 2017 Innokentiy Shushpanov. All rights reserved.
//

import Foundation
import MediaPlayer
import AVKit
import AVFoundation

class AudioPlayer {
    private var beepPlayer : AVAudioPlayer?
    private var shortBeepPlayer : AVAudioPlayer?
    private var throwGoalBeepPlayer : AVAudioPlayer?
    private var fadingCurveIdx = 0
    private var isFading = false
    private var jinglePlayer: JinglePlayer?

    private var beepTimer: Timer?
    private var playerTimer: Timer?
    
    init(withSong song: MPMediaItem) {
        changeSong(song: song)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch{ }
        beepPlayer = getAudioPlayer(forFile: "beep-01a", withExtension: "wav")
        shortBeepPlayer = getAudioPlayer(forFile: "beep-02", withExtension: "wav")
        throwGoalBeepPlayer = getAudioPlayer(forFile: "beep-03", withExtension: "wav")
    }

    deinit {
        stopPlayers()
    }

    func vibrate(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }

    
    func changeSong(song: MPMediaItem) {
        jinglePlayer = song.assetURL == nil ? MusicPlayer() : AvMusicPlayer()
        jinglePlayer?.setJingle(song: song)
    }

    func pauseJingle(){
        jinglePlayer?.pause()
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
        jinglePlayer?.play()
    }

    func longBeep(){
        beepPlayer?.play()
    }
    
    func throwingGoalBeep(){
        self.throwGoalBeepPlayer?.play()
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
        jinglePlayer?.stop()
    }
    
    func fadeOutAndStopPlayer(){
        jinglePlayer?.fadeOutAndStop()
    }
}
