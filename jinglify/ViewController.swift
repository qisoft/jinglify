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
    @IBOutlet weak var pauseGameButton: UIButton!
    @IBOutlet weak var throwThePuckButton: UIButton!
    @IBOutlet weak var currentPeriodLabel: UILabel!

    var gameSettings = GameSettings()
    var game : Game?

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let player = AudioPlayer(withSong: gameSettings.jingle)
        game = Game(withAudioPlayer: player)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let game = self.game {
            game.startGame(withGameEndHandler: {() in
                self.dismiss(animated: true)
            })
            game.statusText.didChange.addHandler { (_, n) in
                self.timeLeftLabel.text = n
            }
            game.currentPeriod.didChange.addHandler { (_, n) in
                self.currentPeriodLabel.text = "Period \(n)"
            }
            game.isPaused.didChange.addHandler { (_, n) in
                self.pauseGameButton.setTitle(n ? "Resume game" : "Pause game", for: .normal)
                self.throwThePuckButton.setTitle(n ? "Resume game and throw the puck!" : "Throw the puck!", for: .normal)
            }
        }
    }

    // MARK: - Event handlers
    @IBAction func onThrowTap(_ sender: Any) {
        game?.throwAPuck()
    }

    @IBAction func onPauseGameTap(_ sender: Any) {
        if let game = self.game {
            if game.isPaused.get() {
                resumeGame()
            }
            else {
                game.pauseGame()
            }
        }
    }

    @IBAction func onStopGameTap(_ sender: Any) {
        let alert = UIAlertController(title: "Stop game", message: "Do you want to stop the game?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { _ in
            self.game?.stopGame()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }

    //MARK: - Game methods

    func resumeGame(){
        game?.resumeGame()
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
}

