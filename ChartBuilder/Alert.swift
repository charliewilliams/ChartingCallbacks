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
        case fileSaveError(_: Error?)
    }

    init(type: AlertType) {
        super.init()

        switch type {
        case .fileLoadError(let e):
            messageText = Text.fileLoadErrorMessage
            if let e = e {
                informativeText = e.localizedDescription
            }
        case .fileSaveError(let e):
            messageText = Text.fileSaveErrorMessage
            if let e = e {
                informativeText = e.localizedDescription
            }
        }

        alertStyle = .warning
        addButton(withTitle: Text.ok)
        runModal()
    }
}
