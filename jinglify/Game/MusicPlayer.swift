//
//  MusicPlayer.swift
//  jinglify
//
//  Created by Ilya Sedov on 25/03/2017.
//  Copyright © 2017 Innokentiy Shushpanov. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicPlayer: JinglePlayer {
    private let player = MPMusicPlayerController.applicationMusicPlayer()
    private var songItem: MPMediaItem?

    func setJingle(song: MPMediaItem) {
        songItem = song
        enqueSong()
    }

    private func enqueSong() {
        if let song = songItem {
            player.setQueue(with: MPMediaItemCollection(items: [song]))
            player.prepareToPlay()
        }
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func stop() {
        isFading = false
        player.stop()
        enqueSong()
    }

    func fadeOutAndStop() {
        isFading = true
        let dtime = DispatchTime(uptimeNanoseconds: 6 * NSEC_PER_SEC)

        DispatchQueue.main.asyncAfter(deadline: dtime) { 
            self.stop()
        }
    }

    var isFading = false
}
