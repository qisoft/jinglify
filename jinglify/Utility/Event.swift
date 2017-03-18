//
// Created by Innokentiy Shushpanov on 18/03/2017.
// Copyright (c) 2017 Innokentiy Shushpanov. All rights reserved.
//

import Foundation

class Event<T> {

    typealias EventHandler = (T) -> ()

    private var eventHandlers = [EventHandler]()

    func addHandler(handler: @escaping EventHandler) {
        eventHandlers.append(handler)
    }

    func raise(values: T) {
        for handler in eventHandlers {
            handler(values)
        }
    }
}
