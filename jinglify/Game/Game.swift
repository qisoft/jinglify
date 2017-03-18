//
//  Game.swift
//  jinglify
//
//  Created by Innokentiy Shushpanov on 18/03/2017.
//  Copyright © 2017 Innokentiy Shushpanov. All rights reserved.
//

import Foundation

class Game {
    private var matchTimeLeft: Double = 0.0
    private var totalMatchTime: Double = 0.0
    private var initialBeepTimeOffset = 0
    private var isGameStarted = false
    private var isJinglePlaying : Bool = false
    private var isThrowing : Bool = false
    private var player : AudioPlayer
    private var settings : GameSettings
    private(set) var isPaused : Bool = false

    private var statusText : String = ""{
        didSet {
            self.statusUpdateHandler?()
        }
    }

    private var gameTimer : Timer?
    private var throwingTimer : Timer?
    private var gameEndHandler : (() -> Void)?
    private var statusUpdateHandler: (() -> Void)?

    init(withAudioPlayer audioPlayer: AudioPlayer) {
        settings = GameSettings()
        player = audioPlayer
        initialBeepTimeOffset = Utils.getRandomBeepTime()
        totalMatchTime = settings.matchTime * 60 + 30 + Double(initialBeepTimeOffset)
        matchTimeLeft = totalMatchTime
    }

    func startGame(withStatusUpdateHandler statusUpdateHandler: @escaping () -> Void,
                   andGameEndHandler gameEndHandler: @escaping () -> Void){
        isGameStarted = true
        self.gameEndHandler = gameEndHandler
        self.statusUpdateHandler = statusUpdateHandler
        self.update(timeLeft: self.totalMatchTime, timeSpent: 0)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in

            if !self.isThrowing && !self.isPaused {
                self.matchTimeLeft = self.matchTimeLeft - 1


                self.update(
                        timeLeft: self.matchTimeLeft,
                        timeSpent: self.totalMatchTime - self.matchTimeLeft)
            }
        }
    }

    func pauseGame(){
        isPaused = true
        statusText = "Paused"
        if isJinglePlaying {
            self.player.pauseJingle()
        }
    }

    func resumeGame(){
        isPaused = false
        if isJinglePlaying {
            self.player.playJingle()
        }
    }

    func stopGame(){
        isGameStarted = false
        player.stopPlayers()
        gameTimer?.invalidate()
        gameTimer = nil
        throwingTimer?.invalidate()
        throwingTimer = nil
        self.gameEndHandler?()
    }

    private func playJingle(){
        isJinglePlaying = true
        self.player.playJingle()
    }

    func getStatusText() -> String{
        return statusText
    }

    func throwAPuck(){
        
        statusText = "Get Ready!"
        player.vibrate()
        if self.isJinglePlaying {
            player.pauseJingle()
        }

        isThrowing = true
        throwingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Utils.getRandomBeepTime()), repeats: false) { (timer) in
            self.player.longBeep()
            if self.isJinglePlaying {
                self.player.playJingle()
            }
            self.isThrowing = false
        }
    }

    private func update(timeLeft: Double, timeSpent: Double){
        print("time spent: \(timeSpent), time left: \(timeLeft)")
        switch timeSpent {
        case 0: self.playJingle()
        case 22:
            self.player.fadeOutAndStopPlayer(onComplete: { () in
                self.isJinglePlaying = false
            })
        case 30+Double(initialBeepTimeOffset): self.player.longBeep()
        default: break
        }

        switch timeLeft {
        case 0:
            self.player.longBeep()
            stopGame()
        case 7: self.player.fadeOutAndStopPlayer(onComplete: { () in
            self.isJinglePlaying = false
        })
        case 30: self.playJingle()
        case 59..<settings.matchTime * 60:
            if timeLeft.truncatingRemainder(dividingBy: 60.0) == 0 {
                self.player.beep(times: Int(timeLeft.divided(by: 60)))
            }
        default: break
        }

        if(timeLeft <= settings.matchTime * 60){
            statusText = Utils.stringFromTimeInterval(interval: timeLeft)
        }
        else if (timeSpent <= 30){
            statusText = "Warm-up!"
        }
        else{
            statusText = "Get Ready!"
        }
    }
}
