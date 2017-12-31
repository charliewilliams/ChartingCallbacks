//
//  ViewController.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 27/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Cocoa
import Quartz

class ViewController: NSViewController {

    var perWordLabels: [NSTextView] = []
    var brackets: [BracketView] = []
    var json: [String: AnyObject]?
    var readURL: URL?

    init(url: URL) {
        super.init(nibName: nil, bundle: nil)

        readURL = url
        loadFile(from: url)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if json == nil {

            loadFile(from: URL(fileURLWithPath: NSString(string: "/Users/cw/Developer/ComedyTokenizer/README-output.json").expandingTildeInPath, isDirectory: false))
//            showOpenPanel()
        }

//        becomeFirstResponder()
    }
}

private extension ViewController {

    func redraw() {

        guard let json = json,
            let fullText = json[Keys.fullText.rawValue] as? [String],
            let analysis = json[Keys.analysis.rawValue] as? [[String: [Int]]] else {
                Alert(type: .fileLoadError(nil)).runModal()
                return
        }

        let layout = json[Keys.layout.rawValue] as? [String: [String: AnyObject]]
        let totalWidth = Layout.tinyWordHorizontalSpacing * CGFloat(fullText.count - 2) + Layout.tinyWordLeftPadding

        // tiny words of full text along the bottom
        for (index, word) in fullText.enumerated() {

            let label = TinyLabel(string: word)
            view.addSubview(label)
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: Layout.tinyWordBottomPadding))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: Layout.tinyWordHorizontalSpacing * CGFloat(index + 1) + Layout.tinyWordLeftPadding))
            perWordLabels.append(label)
        }

        // for each 'callback' make a selectable bracket + label
        for (index, callback) in analysis.enumerated() {

            guard let word = callback.keys.first,
                let indices = callback.values.first else {
                    continue
            }

            // if existing layout info exists, set it on each view
            let bracket = BracketView(word: word, indices: indices, wordCount: fullText.count, layout: layout?[word])
            bracket.color = AppColor.number(index)
            view.addSubview(bracket)

            let views = ["bracket": bracket]
            let metrics = ["top": Layout.bigLabelTopPadding, "bottom": Layout.bracketStartY, "left": Layout.tinyWordLeftPadding, "width": totalWidth] as [String: NSNumber]

            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[bracket(width)]", options: [], metrics: metrics, views: views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[bracket]-(bottom)-|", options: [], metrics: metrics, views: views))

            brackets.append(bracket)
        }
    }

    func loadFile(from url: URL) {

        readURL = url

        if let data = FileManager.default.contents(atPath: url.path) {
            do {
                json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                redraw()
            } catch let e {
                Alert(type: .fileLoadError(e)).runModal()
            }
        }
    }

    func saveFile(to url: URL) {

        // save json
        do {
            let data = try JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
            try data.write(to: url)
        } catch let e {
            Alert(type: .fileSaveError(e)).runModal()
        }

        // export pdf
        guard let bitmapRep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
            return
        }

        view.cacheDisplay(in: view.bounds, to: bitmapRep)
        let image = NSImage(size: view.bounds.size)
        image.addRepresentation(bitmapRep)
        if let page = PDFPage(image: image) {
            let doc = PDFDocument()
            doc.insert(page, at: 0)
            let saveURL = url.deletingPathExtension().appendingPathExtension("pdf")
            doc.write(to: saveURL)
        }

        // what the hell, png too
        if let data = bitmapRep.representation(using: .png, properties: [:]) {
            let saveURL = url.deletingPathExtension().appendingPathExtension("png")

            do {
                try data.write(to: saveURL)
            } catch let e {
                Alert(type: .fileSaveError(e)).runModal()
            }
        }
    }

    func reset() {

        for label in perWordLabels {
            label.removeFromSuperview()
        }
        for bracket in brackets {
            bracket.removeFromSuperview()
        }
        perWordLabels = []
        brackets = []
    }
}

// IBOutlets
extension ViewController {

    @IBAction func showOpenPanel(_ sender: NSMenuItem) {

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
                self.loadFile(from: first)
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

    @IBAction func selectPreviousLayer(_ sender: NSMenuItem) {
        print("HI")
    }

    @IBAction func selectNextLayer(_ sender: NSMenuItem) {
        print("HI")
    }

    @IBAction func save(_ sender: NSMenuItem) {

        guard let readURL = readURL else { return } // todo pop save panels
        saveFile(to: readURL)
    }
}
