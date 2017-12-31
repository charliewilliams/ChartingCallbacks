//
//  BigLabel.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 29/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Cocoa

class BigLabel: NSTextView {

    override var intrinsicContentSize: NSSize {
        let width = string.width(withConstrainedHeight: 60, font: font!)
        return NSSize(width: width * 1.2, height: 60)
    }

    init(string: String) {
        super.init(frame: .zero)

        self.string = "\"\(string)\""

        font = NSFont.systemFont(ofSize: 48)
        translatesAutoresizingMaskIntoConstraints = false
        alignment = .center
        isSelectable = false
    }

    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
