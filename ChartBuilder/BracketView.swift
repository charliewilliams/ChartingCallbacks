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
    var color: NSColor = .red
    var mainLabelX: CGFloat = 0 {
        didSet {
            mainLabelLeadingConstraint?.isActive = false
            mainLabelLeadingConstraint = NSLayoutConstraint(item: mainLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: mainLabelX)
            mainLabelLeadingConstraint?.isActive = true
            layout()
        }
    }
    private let totalWordCount: Int
    private var bezierPaths: [NSBezierPath] = []
    private var mainLabelLeadingConstraint: NSLayoutConstraint?
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(phrase: String, indices: [Int], totalWordCount: Int, layout: [String: AnyObject]?) {

        self.phrase = phrase
        self.indices = indices
        self.totalWordCount = totalWordCount
        mainLabel = BigLabel(string: phrase)

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainLabel)
        addConstraint(NSLayoutConstraint(item: mainLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.25, constant: 0))
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectBracket(_:)), name: bracketSelectedNotification, object: nil)
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

    let bracketSelectedNotification = Notification.Name("bracketSelectedNotification")
    @objc func didSelectBracket(_ note: Notification) {

        guard let bracket = note.object as? BracketView, bracket != self else { return }

        isSelected = false
    }
}
