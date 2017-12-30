//
//  Keys.swift
//  ChartingCallbacks
//
//  Created by Charlie Williams on 29/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Foundation

enum Keys: String {
    case fullText
    case analysis
    case layout

    case labelPosition
    case color
    case alpha
}

struct Text {
    static var ok: String { return "OK" }
    static var fileOpenMessage: String { return "Open one or more files, or a folder" }
    static var fileLoadErrorMessage: String { return "Badly structured JSON file!" }
}
