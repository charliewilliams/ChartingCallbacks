//
//  ViewController.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 27/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var perWordStackView: NSStackView!
    var perWordLabels: [AnyObject] = []
    var loadedJSON: [String: AnyObject]? {
        didSet {
            guard let loadedJSON = loadedJSON else { return }

            // draw to screen
            guard let fullText = loadedJSON[Keys.fullText.rawValue] as? [String],
            let analysis = loadedJSON[Keys.analysis.rawValue] else {
                Alert(type: .fileLoadError(nil)).runModal()
                return
            }

            for word in fullText {

                let label = TinyLabel(string: word)
//                perWordStackView.addSubview(label)
                view.addSubview(label)
                // pin to bottom
                view.addConstraint(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: Layout.tinyWordBottomPadding))
                // pin to previous + equal height
                if let previous = perWordLabels.last {
                    view.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: previous, attribute: .trailing, multiplier: 1.0, constant: Layout.tinyWordHorizontalSpacing))
                    view.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: previous, attribute: .height, multiplier: 1.0, constant: 0))
                } else {
                    view.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: Layout.leftMargin))
                }
                perWordLabels.append(label)
            }
            view.layoutSubtreeIfNeeded()
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
        perWordLabels = []
        for view in perWordStackView.subviews {
            view.removeFromSuperview()
        }
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
