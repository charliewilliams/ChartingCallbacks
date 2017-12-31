//
//  TinyLabel.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 29/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Cocoa

class TinyLabel: NSTextView {

    override var intrinsicContentSize: NSSize {
        return NSSize(width: 100, height: 10)
    }

    init(string: String) {
        super.init(frame: .zero)

        self.string = string

        font = NSFont.systemFont(ofSize: 8)
        translatesAutoresizingMaskIntoConstraints = false
        frameRotation = 90
        alignment = .right
        isSelectable = false
    }

    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
