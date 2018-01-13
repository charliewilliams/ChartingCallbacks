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
        return NSSize(width: Layout.tinyWordHorizontalSpacing * 10, height: Layout.tinyWordHorizontalSpacing * 10)
    }

    override var wantsDefaultClipping: Bool {
        return false
    }

    convenience init(words: [String], totalWidth: CGFloat = 2048) {
        self.init(string: words.joined(separator: "\n"))
    }

    init(string: String, fontSize: CGFloat = Layout.tinyWordHorizontalSpacing * 0.8) {
        super.init(frame: .zero)

        self.string = string

        wantsLayer = true

        let layer = CATextLayer()
        layer.string = string
        layer.font = NSFont.systemFont(ofSize: fontSize)
//        layer.fontSize = fontSize
//        layer.setAffineTransform(CGAffineTransform(rotationAngle: 90))
        layer.foregroundColor = NSColor.black.cgColor
        layer.alignmentMode = kCAAlignmentRight

        self.layer = layer

        translatesAutoresizingMaskIntoConstraints = false
//        font = NSFont.systemFont(ofSize: fontSize)
//        alignment = .right
        isSelectable = false
        drawsBackground = true
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

//    override func draw(_ dirtyRect: NSRect) {
//
//        let rotate = CATransform3DMakeRotation(90.degreesToRadians, 0, 0, 1)
//        let translate = CATransform3DMakeTranslation(bounds.width, 0, 0)
//        layer?.transform = CATransform3DConcat(rotate, translate)
//
//        super.draw(dirtyRect)
//    }
}
