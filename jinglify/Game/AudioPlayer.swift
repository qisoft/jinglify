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

    private var beepTimer: Timer?
    private var playerTimer: Timer?

    init(withSong song: MPMediaItem){
        do {
            player = try AVAudioPlayer(contentsOf: song.value(forProperty: MPMediaItemPropertyAssetURL) as! URL)
            player?.prepareToPlay()
        } catch { }
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

    func pauseJingle(){
        player?.pause()
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

    private func getVolume() -> Float{
        return player?.volume ?? 0
    }

    private func setVolume(to value: Float){
        player?.volume = value
    }

    func fadeOutAndStopPlayer(onComplete: @escaping () -> Void){
        playerTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in

            self.setVolume(to: self.getVolume() - 0.1)
            if(self.getVolume() == 0){
                self.player?.stop()
                onComplete()
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                    self.setVolume(to: 1.0)
                })
                self.playerTimer?.invalidate()
                self.playerTimer = nil
            }
        })

    }
}
