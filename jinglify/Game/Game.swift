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
    private var totalPeriods : Int
    private(set) var isPaused : Bool = false
    private(set) var currentPeriod = Observable<Int>(1)
    private(set) var statusText = Observable<String>("")

    private var gameTimer : Timer?
    private var throwingTimer : Timer?
    private var gameEndHandler : (() -> Void)?

    init(withAudioPlayer audioPlayer: AudioPlayer) {
        settings = GameSettings()
        player = audioPlayer
        initialBeepTimeOffset = Utils.getRandomBeepTime()
        totalMatchTime = settings.matchTime * 60 + 30 + Double(initialBeepTimeOffset)
        matchTimeLeft = totalMatchTime
        totalPeriods = settings.periodsCount >= 1 ? settings.periodsCount : 1
    }

    func startGame(withGameEndHandler gameEndHandler: @escaping () -> Void){
        isGameStarted = true
        self.gameEndHandler = gameEndHandler
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in

            if !self.isThrowing && !self.isPaused {
                self.update(
                        timeLeft: self.matchTimeLeft,
                        timeSpent: self.totalMatchTime - self.matchTimeLeft)
                self.matchTimeLeft = self.matchTimeLeft - 1
            }
        }
    }

    func pauseGame(){
        isPaused = true
        statusText.set(newValue: "Paused")
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

    func throwAPuck(){
        
        statusText.set(newValue: "Get Ready!")
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
    
    private func startNewPeriod(){
        try player.changeSong(song: settings.jingle)
        self.currentPeriod.set(newValue: self.currentPeriod.get() + 1)
        self.matchTimeLeft = totalMatchTime + 10
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
            if currentPeriod.get() == totalPeriods {
                self.stopGame()
            }
            else {
                self.startNewPeriod()
            }
            return
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

        if(timeSpent < 0){
            statusText.set(newValue: "Change your sides!")
        }
        else if(timeLeft <= settings.matchTime * 60){
            statusText.set(newValue: Utils.stringFromTimeInterval(interval: timeLeft))
        }
        else if (timeSpent >= 0 && timeSpent <= 30){
            statusText.set(newValue: "Warm-up!")
        }
        else{
            statusText.set(newValue: "Get Ready!")
        }
    }
}
