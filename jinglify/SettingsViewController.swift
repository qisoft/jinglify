//
//  SettingsViewController.swift
//  jinglify
//
//  Created by Ilya Sedov on 07/02/2017.
//  Copyright © 2017 Innokentiy Shushpanov. All rights reserved.
//

import UIKit
import MediaPlayer

struct GameSettings {
    var matchTime: Double = 5.0
    var songs = MPMediaItemCollection(items: Array<MPMediaItem>())
}

class SettingsViewController: UIViewController, MPMediaPickerControllerDelegate {

    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var matchTimeLabel: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var startButton: UIButton!

    var gameSettings = GameSettings()


    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.isEnabled = false
    }

    // MARK: - MPMediaPickerControllerDelegate impl
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection)
    {
        mediaPicker.dismiss(animated: true)

        gameSettings.songs = mediaItemCollection
        if(mediaItemCollection.count > 0)
        {
            let song = mediaItemCollection.items[0]
            songArtist.text = song.artist ?? "-"
            songTitle.text = song.title ?? "-"
            startButton.isEnabled = true
            startButton.backgroundColor = UIColor.init(red: 52 / 255,
                                                       green: 94 / 255,
                                                       blue: 242 / 255,
                                                       alpha: 1.0)
        }
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }

    //MARK: - Actions

    @IBAction func onChooseButtonTap(_ sender: Any) {
        let controller = MPMediaPickerController(mediaTypes: MPMediaType.music)
        controller.delegate = self
        controller.allowsPickingMultipleItems = true
        self.present(controller, animated: true)
    }

    @IBAction func matchTimeChanged(_ sender: Any) {
        gameSettings.matchTime = (sender as! UIStepper).value
        matchTimeLabel.text = "\(Int(gameSettings.matchTime)) min"
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "startGame") {
            if let gameVC = segue.destination as? ViewController {
                gameVC.gameSettings = gameSettings
            }
        }
    }

}
