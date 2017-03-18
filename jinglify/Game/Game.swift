//
//  Game.swift
//  jinglify
//
//  Created by Innokentiy Shushpanov on 18/03/2017.
//  Copyright © 2017 Innokentiy Shushpanov. All rights reserved.
//

import Foundation

class Game {
    private var matchTimeLeft: Int = 0
    private var totalMatchTime: Int = 0
    private var initialBeepTimeOffset = 0
    private var isGameStarted = false
    private var lastHandledTime : Int = -1
    private var isJinglePlaying : Bool = false
    private var player : AudioPlayer
    private var settings : GameSettings
    private var totalPeriods : Int
    private(set) var isPaused = Observable<Bool>(false)
    private(set) var currentPeriod = Observable<Int>(1)
    private(set) var statusText = Observable<String>("")

    private var gameTimer : Timer?
    private var throwingTimer : Timer?
    private var gameEndHandler : (() -> Void)?
    private(set) static var currentGame : Game?

    init(withAudioPlayer audioPlayer: AudioPlayer) {
        settings = GameSettings()
        player = audioPlayer
        initialBeepTimeOffset = Utils.getRandomBeepTime()
        totalMatchTime = Int(settings.matchTime * 60) + 30 + initialBeepTimeOffset
        matchTimeLeft = totalMatchTime
        totalPeriods = settings.periodsCount >= 1 ? settings.periodsCount : 1
        Game.currentGame = self
    }

    func startGame(withGameEndHandler gameEndHandler: @escaping () -> Void){
        isGameStarted = true
        self.gameEndHandler = gameEndHandler
        self.setupGameTimer()
    }

    private func setupGameTimer(){
        if let gameTimer = self.gameTimer {
            gameTimer.invalidate()
        }

        self.update(timeLeft: self.matchTimeLeft,
                timeSpent: self.totalMatchTime - self.matchTimeLeft)
        self.gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.matchTimeLeft = self.matchTimeLeft - 1
            self.update(timeLeft: self.matchTimeLeft,
                    timeSpent: self.totalMatchTime - self.matchTimeLeft)
        }
    }

    func pauseGame(){
        self.isPaused.set(newValue: true)
        self.invalidateTimers()
        self.statusText.set(newValue: "Paused")
        if self.isJinglePlaying {
            self.player.pauseJingle()
        }
    }

    func resumeGame(){
        self.isPaused.set(newValue: false)
        self.setupGameTimer()
        if isJinglePlaying {
            self.player.playJingle()
        }
    }

    private func invalidateTimers(){
        self.gameTimer?.invalidate()
        self.gameTimer = nil
        self.throwingTimer?.invalidate()
        self.throwingTimer = nil
    }

    func stopGame(){
        self.isGameStarted = false
        self.invalidateTimers()
        self.player.stopPlayers()
        self.gameEndHandler?()
    }

    private func playJingle(){
        self.isJinglePlaying = true
        self.player.playJingle()
    }

    func throwAPuck(){
        
        statusText.set(newValue: "Get Ready!")
        self.isPaused.set(newValue: false)
        player.vibrate()
        if self.isJinglePlaying {
            player.pauseJingle()
        }

        self.invalidateTimers()
        self.throwingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Utils.getRandomBeepTime()), repeats: false) { (timer) in
            self.player.longBeep()
            if self.isJinglePlaying {
                self.player.playJingle()
            }
            self.setupGameTimer()
        }
    }
    
    private func startNewPeriod(){
        self.player.changeSong(song: settings.jingle)
        self.currentPeriod.set(newValue: self.currentPeriod.get() + 1)
        self.matchTimeLeft = totalMatchTime + 10
    }

    private func updateStatus(timeLeft: Int, timeSpent: Int){
        if(timeSpent < 0){
            statusText.set(newValue: "Change your sides!")
        }
        else if(timeLeft <= Int(settings.matchTime * 60)){
            statusText.set(newValue: Utils.stringFromTimeInterval(interval: Double(timeLeft)))
        }
        else if (timeSpent >= 0 && timeSpent <= 27){
            statusText.set(newValue: "Warm-up!")
        }
        else{
            statusText.set(newValue: "Get Ready!")
        }
    }

    private func update(timeLeft: Int, timeSpent: Int){
        self.updateStatus(timeLeft: timeLeft, timeSpent: timeSpent)

        // prevent events from occurring twice
        if lastHandledTime == timeSpent {
            return
        }
        lastHandledTime = timeSpent

        print("time spent: \(timeSpent), time left: \(timeLeft)")
        switch timeSpent {
        case 0:
            self.playJingle()
        case 22:
            self.player.fadeOutAndStopPlayer()
        case 30:
            self.isJinglePlaying = false
        case 30+initialBeepTimeOffset: self.player.longBeep()
        default: break
        }

        switch timeLeft {
        case 0:
            self.player.longBeep()
            self.isJinglePlaying = false
            if currentPeriod.get() == totalPeriods {
                self.stopGame()
            }
            else {
                self.startNewPeriod()
            }
            return
        case 7: self.player.fadeOutAndStopPlayer()
        case 30: self.playJingle()
        case 59..<Int(settings.matchTime * 60):
            if timeLeft % 60 == 0 {
                self.player.beep(times: Int(timeLeft / 60))
            }
        default: break
        }
    }
}
