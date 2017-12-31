//
//  File.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 29/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Cocoa

class BracketView: NSView {

    let phrase: String
    let indices: [Int]
    private let totalWordCount: Int
    private let mainLabel: NSTextView
    private var bezierPaths: [NSBezierPath] = []
    var color: NSColor = .red
    var mainLabelPosition = CGPoint(x: 0.5, y: 0.15)

    init(phrase: String, indices: [Int], totalWordCount: Int, layout: [String: AnyObject]?) {

        self.phrase = phrase
        self.indices = indices
        self.totalWordCount = totalWordCount
        mainLabel = BigLabel(string: phrase)

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainLabel)

        addConstraint(NSLayoutConstraint(item: mainLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: mainLabelPosition.x * 2, constant: 0))
        addConstraint(NSLayoutConstraint(item: mainLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: mainLabelPosition.y * 2, constant: 0))

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

    override func draw(_ dirtyRect: NSRect) {

        if bezierPaths.isEmpty {
            buildBezierPaths()
        }

        // Draw bezier paths
        for path in bezierPaths {
            color.set()
            path.stroke()
            path.fill()
        }
    }

    override func layout() {
        super.layout()

        buildBezierPaths()
    }

    private func buildBezierPaths() {

        let endPoint = CGPoint(x: mainLabel.frame.midX, y: mainLabel.frame.minY)
        let xPerIndex = bounds.width / CGFloat(totalWordCount)

        bezierPaths = indices.map { (index) -> NSBezierPath in

            let start = CGPoint(x: xPerIndex * CGFloat(index), y: 0)

            // for now just a line to the main label's bottom center point
            let path = NSBezierPath()
            path.move(to: start)
            path.line(to: endPoint)

            path.lineWidth = 5

            return path
        }
    }
}
