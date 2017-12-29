//
//  Alert.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 29/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Cocoa

class Alert: NSAlert {

    enum AlertType {
        case fileLoadError(_: Error?)
    }

    init(type: AlertType) {
        super.init()

        messageText = Text.fileLoadErrorMessage

        switch type {
        case .fileLoadError(let e):
            if let e = e {
                informativeText = e.localizedDescription
            }
        }
        alertStyle = .warning
        addButton(withTitle: Text.ok)
        runModal()
    }
}
