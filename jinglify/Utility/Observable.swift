//
// Created by Innokentiy Shushpanov on 18/03/2017.
// Copyright (c) 2017 Innokentiy Shushpanov. All rights reserved.
//

import Foundation

class Observable<T> {

    let didChange = Event<(T, T)>()
    private var value: T

    init(_ initialValue: T) {
        value = initialValue
    }

    func set(newValue: T) {
        let oldValue = value
        value = newValue
        didChange.raise(values: (oldValue, newValue))
    }

    func get() -> T {
        return value
    }
}
