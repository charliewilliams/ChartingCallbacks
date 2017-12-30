//
//  File.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 29/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Cocoa

class BracketView: NSView {

    private let word: String
    private let indices: [Int]
    let mainLabel: NSTextView
    var bezierPaths: [NSBezierPath] = []
    var color: NSColor = .red

    init(word: String, indices: [Int]) {

        self.word = word
        self.indices = indices
        mainLabel = BigLabel(string: word)

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainLabel)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubtreeIfNeeded() {

        mainLabel.removeConstraints(mainLabel.constraints)

        addConstraint(NSLayoutConstraint(item: mainLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: mainLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))

        super.layoutSubtreeIfNeeded()
    }

    override func draw(_ dirtyRect: NSRect) {

        NSColor.orange.setFill()
        dirtyRect.fill()

        // Draw bezier paths
        for path in bezierPaths {
            color.set()
            path.stroke()
        }

        // Call super to draw subviews for free
        super.draw(dirtyRect)
    }

    private func buildBezierPaths() {

        let endPoint = CGPoint(x: mainLabel.frame.midX, y: mainLabel.frame.minY)

        bezierPaths = indices.map { (index) -> NSBezierPath in

            let start = CGPoint(x: CGFloat(index) / bounds.width, y: 0)

            // for now just a line to the main label's bottom center point
            let path = NSBezierPath()
            path.move(to: start)
            path.line(to: endPoint)

            return path
        }
    }
}
