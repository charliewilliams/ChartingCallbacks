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
    var mainLabelPosition = CGPoint(x: 0.5, y: 0.5)

    init(word: String, indices: [Int], layout: [String: AnyObject]?) {

        self.word = word
        self.indices = indices
        mainLabel = BigLabel(string: word)

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainLabel)

        if let layout = layout {
            if let labelPosition = layout[Keys.labelPosition.rawValue] as? CGPoint {
                mainLabelPosition = labelPosition
            }
            if let color = layout[Keys.color.rawValue] as? NSColor {
                self.color = color
            }
            if let alpha = layout[Keys.alpha.rawValue] as? CGFloat {
                alphaValue = alpha
            }
        }
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubtreeIfNeeded() {

        mainLabel.removeConstraints(mainLabel.constraints)

        addConstraint(NSLayoutConstraint(item: mainLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: mainLabelPosition.x * 2, constant: 0))
        addConstraint(NSLayoutConstraint(item: mainLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: mainLabelPosition.y * 2, constant: 0))

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
