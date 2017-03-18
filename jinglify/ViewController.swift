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

    var gameSettings = GameSettings()
    var game : Game?

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        game = Game(withAudioPlayer: AudioPlayer(withSong: gameSettings.jingle))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let game = self.game {
            game.startGame(withGameUpdateHandler: { () in
                self.timeLeftLabel.text = game.getStatusText()
            }, andGameEndHandler: {() in
                self.dismiss(animated: true)
            })
        }
    }

    // MARK: - Event handlers
    @IBAction func onThrowTap(_ sender: Any) {
        game?.throwAPuck()
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

