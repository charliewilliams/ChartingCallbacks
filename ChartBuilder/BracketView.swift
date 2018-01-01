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
    let mainLabel: NSTextView
    var manuallyHidden: Bool = false
    var isSelected: Bool = false {
        didSet {
            mainLabel.layer?.borderColor = isSelected ? NSColor.red.cgColor : nil
            mainLabel.layer?.borderWidth = isSelected ? 1 : 0

            if isSelected {
                NotificationCenter.default.post(Notification(name: bracketSelectedNotification, object: self))
            }
        }
    }
    override var isSelectable: Bool { return true }
    var mainLabelX: CGFloat = 0 {
        didSet {
            mainLabelLeadingConstraint?.isActive = false
            mainLabelLeadingConstraint = NSLayoutConstraint(item: mainLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: mainLabelX)
            mainLabelLeadingConstraint?.isActive = true
        }
    }
    var mainLabelY: CGFloat = 0 {
        didSet {
            mainLabelTopConstraint?.isActive = false
            mainLabelTopConstraint = NSLayoutConstraint(item: mainLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: Layout.bigLabelTopPadding + mainLabelY)
            mainLabelTopConstraint?.isActive = true
        }
    }
    private let color: NSColor
    private let totalWordCount: Int
    private var bezierPaths: [NSBezierPath] = []
    private var mainLabelLeadingConstraint: NSLayoutConstraint?
    private var mainLabelTopConstraint: NSLayoutConstraint?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(phrase: String, indices: [Int], totalWordCount: Int, color: NSColor, layout: [String: AnyObject]?) {

        self.phrase = phrase
        self.indices = indices
        self.totalWordCount = totalWordCount
        self.color = color
        mainLabel = BigLabel(string: phrase)

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainLabel)
        mainLabelTopConstraint = NSLayoutConstraint(item: mainLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.25, constant: 0)
        mainLabelTopConstraint?.isActive = true

        NotificationCenter.default.addObserver(self, selector: #selector(didSelectBracket(_:)), name: bracketSelectedNotification, object: nil)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {

//        NSColor.orange.withAlphaComponent(0.1).setFill()
//        dirtyRect.fill()

        if bezierPaths.isEmpty {
            buildBezierPaths()
        }

        // Draw bezier paths
        for path in bezierPaths {
            color.set()
            path.stroke()
        }
    }

    override func layout() {
        super.layout()

        buildBezierPaths()
    }

    private let curve = true
    private func buildBezierPaths() {

        let endPoint = CGPoint(x: mainLabel.frame.midX, y: mainLabel.frame.minY)
        let xPerIndex = bounds.width / CGFloat(totalWordCount)

        bezierPaths = indices.map { (index) -> NSBezierPath in

            let start = CGPoint(x: xPerIndex * CGFloat(index), y: 0)
            let path = NSBezierPath()
            path.lineWidth = 5
            path.move(to: start)

            if curve {

                let isLeftOfMidpoint = start.x < endPoint.x / 2
                let cp1XMult: CGFloat = isLeftOfMidpoint ? 1.2 : 0.8
                let cp2XMult: CGFloat = isLeftOfMidpoint ? 0.8 : 1.2
                let cp1 = CGPoint(x: start.x * cp1XMult, y: 150)
                let cp2 = CGPoint(x: endPoint.x * cp2XMult, y: endPoint.y - 40)

                path.curve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)

            } else {

                path.line(to: endPoint)
            }

            return path
        }
    }

    let bracketSelectedNotification = Notification.Name("bracketSelectedNotification")
    @objc func didSelectBracket(_ note: Notification) {

        guard let bracket = note.object as? BracketView, bracket != self else { return }

        isSelected = false
    }
}
