//
// Created by Innokentiy Shushpanov on 18/03/2017.
// Copyright (c) 2017 Innokentiy Shushpanov. All rights reserved.
//

import Foundation
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
