//
//  TracksTableViewController.swift
//  jinglify
//
//  Created by Ilya Sedov on 10/02/2017.
//  Copyright © 2017 Innokentiy Shushpanov. All rights reserved.
//

import UIKit
import MediaPlayer

class TracksTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
    }

    var tracks = [MPMediaItem]() {
        didSet {
            self.tableView?.reloadData()
        }
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tableView.reloadData()
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath)
        if let trackCell = cell as? TrackCell {
            let track = tracks[indexPath.row]
            trackCell.trackTitle.text = track.title
            trackCell.artist.text = track.artist
            let artSize = trackCell.albumArt.bounds.size 
            trackCell.albumArt.image = track.artwork?.image(at: artSize)
        }

        return cell
    }
}
