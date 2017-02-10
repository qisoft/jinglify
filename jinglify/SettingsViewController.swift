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

        songs = MPMediaItemCollection(items: [])
        if let ids = UserDefaults.standard.array(forKey: songsKey) as? [UInt64],
            ids.count > 0
        {
            songs = MPMediaItemCollection(items:
                ids.map({ (id) -> MPMediaPredicate in
                    return MPMediaPropertyPredicate(value: id,
                                                    forProperty: MPMediaItemPropertyPersistentID)
                }).flatMap({ (predicate) in
                    let query = MPMediaQuery()
                    query.addFilterPredicate(predicate)
                    return query.items?.first
                }))
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

    var jingle: MPMediaItem {
        get {
            let itemIndex = Int(arc4random_uniform(UInt32(songs.items.count)))
            return songs.items[itemIndex]
        }
    }

    private func save() {
        let ids = songs.items.map { $0.persistentID }
        UserDefaults.standard.set(ids, forKey: songsKey)
        UserDefaults.standard.set(matchTime, forKey: matchTimeKey)
        UserDefaults.standard.synchronize()
    }
}

class SettingsViewController: UIViewController, MPMediaPickerControllerDelegate {

    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var matchTimeLabel: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timeStepper: UIStepper!
    @IBOutlet weak var tracksContainer: UIView!

    var tracksCollection: TracksTableViewController?

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
            tracksContainer.isHidden = false
            tracksCollection?.tracks = gameSettings.songs.items
            startButton.isEnabled = true
            startButton.backgroundColor = UIColor.init(red: 52 / 255,
                                                       green: 94 / 255,
                                                       blue: 242 / 255,
                                                       alpha: 1.0)
        } else {
            tracksContainer.isHidden = true
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
        if (segue.identifier == "tracksCollection") {
            tracksCollection = segue.destination as? TracksTableViewController
        }
    }
    
}
