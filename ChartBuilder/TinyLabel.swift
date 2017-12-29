//
//  TinyLabel.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 29/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Cocoa

class TinyLabel: NSTextView { // NSTextField

    override var intrinsicContentSize: NSSize {

        if layoutOrientation != .horizontal {
            print("here")
        }
        return NSSize(width: 10, height: 10)
    }

    override var wantsDefaultClipping: Bool {
        return false
    }

    init(string: String) {
        super.init(frame: .zero)

        self.string = string
//        stringValue = string
        layout()
        font = NSFont.systemFont(ofSize: 8)
        translatesAutoresizingMaskIntoConstraints = false
        frameRotation = -90
        backgroundColor = .red
        layer?.masksToBounds = false
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
