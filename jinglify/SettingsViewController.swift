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

    private let matchTimeKey = "matchTime"
    private let songsKey = "songs"

    init() {
        let savedMatchTime = UserDefaults.standard.double(forKey: matchTimeKey)
        if (savedMatchTime == 0.0) {
            matchTime = 5.0
        } else {
            matchTime = savedMatchTime
        }

        songs = MPMediaItemCollection(items: Array<MPMediaItem>())
        if let ids = UserDefaults.standard.array(forKey: songsKey) as? [UInt64] {
            let predicates = ids.map({ (id) -> MPMediaPredicate in
                return MPMediaPropertyPredicate.init(value: id, forProperty: MPMediaItemPropertyPersistentID)
            })
            let query = MPMediaQuery(filterPredicates: Set(predicates))
            if let qItems = query.items {
                songs = MPMediaItemCollection(items: qItems)
            }
        }
    }

    var matchTime: Double {
        didSet {
            save()
        }
    }
    var songs: MPMediaItemCollection {
        didSet {
            save()
        }
    }

    private func save() {
        let ids = songs.items.map { $0.persistentID }
        UserDefaults.standard.set(ids, forKey: songsKey)
        UserDefaults.standard.set(matchTime, forKey: matchTimeKey)
    }
}

class SettingsViewController: UIViewController, MPMediaPickerControllerDelegate {

    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var matchTimeLabel: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timeStepper: UIStepper!

    var gameSettings = GameSettings()

    //MARK: - Lifecycle 

    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.isEnabled = false
        showSelectSong()
        timeStepper.value = gameSettings.matchTime
        matchTimeChanged(timeStepper)
    }

    func showSelectSong() {
        if (gameSettings.songs.count > 0) {
            let song = gameSettings.songs.items.first
            songArtist.text = song?.artist ?? "-"
            songTitle.text = song?.title ?? "-"
            startButton.isEnabled = true
            startButton.backgroundColor = UIColor.init(red: 52 / 255,
                                                       green: 94 / 255,
                                                       blue: 242 / 255,
                                                       alpha: 1.0)
        }
    }

    // MARK: - MPMediaPickerControllerDelegate impl
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection)
    {
        mediaPicker.dismiss(animated: true)
        gameSettings.songs = mediaItemCollection
        showSelectSong()
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
