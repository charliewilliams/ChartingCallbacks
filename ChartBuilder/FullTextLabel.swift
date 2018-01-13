//
//  FullTextLabel.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 13/01/2018.
//  Copyright © 2018 Charlie Williams. All rights reserved.
//

import Cocoa

class FullTextLabel: NSTextView {

    init(text: [String]) {
        super.init(frame: .zero)

        font = NSFont.systemFont(ofSize: Layout.tinyWordHorizontalSpacing * 0.8)
        translatesAutoresizingMaskIntoConstraints = false
        frameRotation = 90
        alignment = .right
        isSelectable = false
        drawsBackground = true

        string = text.joined(separator: "\n")
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

    override func draw(_ dirtyRect: NSRect) {
        
        if let context = NSGraphicsContext.current {
            context.shouldAntialias = false
            context.cgContext.setShouldAntialias(true)
            context.cgContext.setShouldSmoothFonts(false)
        }

        super.draw(dirtyRect)
    }
    
}
