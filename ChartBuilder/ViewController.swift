//
//  ViewController.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 27/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var perWordLabels: [NSTextView] = []
    var brackets: [BracketView] = []
    var loadedJSON: [String: AnyObject]? {
        didSet {
            guard let loadedJSON = loadedJSON else { return }

            // draw to screen
            guard let fullText = loadedJSON[Keys.fullText.rawValue] as? [String],
            let analysis = loadedJSON[Keys.analysis.rawValue]?.firstObject as? [String: [Int]] else {
                Alert(type: .fileLoadError(nil)).runModal()
                return
            }

            let layout = loadedJSON[Keys.layout.rawValue] as? [String: [String: AnyObject]]
            let totalWidth = Layout.tinyWordHorizontalSpacing * CGFloat(fullText.count + 1) + Layout.tinyWordLeftPadding

            // tiny words of full text along the bottom
            for (index, word) in fullText.enumerated() {

                let label = TinyLabel(string: word)
                view.addSubview(label)
                view.addConstraint(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: Layout.tinyWordBottomPadding))
                view.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: Layout.tinyWordHorizontalSpacing * CGFloat(index + 1) + Layout.tinyWordLeftPadding))
                perWordLabels.append(label)
            }

            // for each 'callback' make a selectable bracket + label
            for (word, indices) in analysis {

                // if existing layout info exists, set it on each view
                let bracket = BracketView(word: word, indices: indices, layout: layout?[word])
                view.addSubview(bracket)

                let views = ["bracket": bracket]
                let metrics = ["top": Layout.bigLabelTopPadding, "bottom": Layout.bracketStartY, "left": Layout.tinyWordLeftPadding, "width": totalWidth] as [String: NSNumber]

                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[bracket(width)]", options: [], metrics: metrics, views: views))
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[bracket]-(bottom)-|", options: [], metrics: metrics, views: views))

                brackets.append(bracket)
            }
        }
    }

    init(url: URL) {
        super.init(nibName: nil, bundle: nil)

        loadFile(fromURL: url)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func reset() {

        for label in perWordLabels {
            label.removeFromSuperview()
        }
        for bracket in brackets {
            bracket.removeFromSuperview()
        }
        perWordLabels = []
        brackets = []
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if loadedJSON == nil {

            loadFile(fromURL: URL(fileURLWithPath: NSString(string: "/Users/cw/Developer/ComedyTokenizer/README-output.json").expandingTildeInPath, isDirectory: false))
//            showOpenPanel()
        }
    }

    func showOpenPanel() {

        // if loadedJSON is nil, show an open dialog
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.allowedFileTypes = ["json"]
        panel.directoryURL = URL(fileURLWithPath: NSString(string: "~/Developer/ComedyTokenizer/README-output.json").expandingTildeInPath, isDirectory: false)
        panel.begin { response in

            guard response == NSApplication.ModalResponse.OK else { return }

            let urls = panel.urls

            if let first = urls.first {
                self.loadFile(fromURL: first)
            }
            if urls.count > 1 {
                for url in urls.dropFirst() {
                    let newWindow = NSWindow()
                    newWindow.contentViewController = ViewController(url: url)
                    newWindow.becomeKey()
                }
            }
        }
    }

    func loadFile(fromURL url: URL) {

        if let data = FileManager.default.contents(atPath: url.path) {
            do {
                representedObject = try JSONSerialization.jsonObject(with: data, options: [])
            } catch let e {
                Alert(type: .fileLoadError(e)).runModal()
            }
        }
    }

    override var representedObject: Any? {
        didSet {
            if let object = representedObject as? [String: AnyObject] {
                loadedJSON = object
            }
        }
    }
}
