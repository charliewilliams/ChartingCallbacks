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
        return NSSize(width: Layout.tinyWordHorizontalSpacing * CGFloat(string.count), height: Layout.tinyWordHorizontalSpacing * 10)
    }

    override var wantsDefaultClipping: Bool {
        return false
    }

    init(words: [String], totalWidth: CGFloat) {
        super.init(frame: .zero)

        self.string = words.joined(separator: "\n")

        let lineHeight = totalWidth / CGFloat(words.count)
        var font = NSFont.systemFont(ofSize: lineHeight)
        var fontSize = lineHeight
        
        while layoutManager!.defaultLineHeight(for: font) > lineHeight {
            autoreleasepool {
                fontSize -= 1
                font = NSFont.systemFont(ofSize: fontSize)
            }
        }

        translatesAutoresizingMaskIntoConstraints = false
        self.font = font
        alignment = .right
        isSelectable = false
        drawsBackground = true
        boundsRotation = -90
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
