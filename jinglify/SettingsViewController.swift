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
    var songs: [MPMediaItem]
}

class SettingsViewController: UIViewController, MPMediaPickerControllerDelegate {

    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var matchTimeLabel: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var startButton: UIButton!

    var gameSettings = GameSettings(matchTime: 5.0, songs: Array<MPMediaItem>())


    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.isEnabled = false

        // Do any additional setup after loading the view.
    }

    var songsList = [MPMediaItem]()

    // MARK: - MPMediaPickerControllerDelegate impl
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true)
        //        if (mediaItemCollection.count > 0) {
        //            songsList = mediaItemCollection.items
        //        }


        if(mediaItemCollection.count > 0)
        {
            let song = mediaItemCollection.items[0]
            songArtist.text = song.artist ?? "-"
            songTitle.text = song.title ?? "-"
//            player?.setQueue(with: mediaItemCollection)
//            player?.nowPlayingItem = song
//            player?.prepareToPlay()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
