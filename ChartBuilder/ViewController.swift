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
        listenForKeyDown()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        readURL = URL(fileURLWithPath: NSString(string: "/Users/cw/Developer/ComedyTokenizer/README-output.json").expandingTildeInPath, isDirectory: false)
        listenForKeyDown()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if json != nil { return }

        if let url = readURL {
            loadFile(from: url)
        } else {
            showOpenPanel()
        }
    }
}

private extension ViewController {

    func redraw() {

        guard let window = view.window,
            let json = json,
            let fullText = json[Keys.fullText.rawValue] as? [String],
            let analysis = json[Keys.analysis.rawValue] as? [String: [Int]] else {
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

            // if existing layout info exists, set it on each view
            let bracket = BracketView(phrase: callback.key, indices: callback.value, totalWordCount: fullText.count, layout: layout?[callback.key])
            bracket.color = AppColor.number(index)
            view.addSubview(bracket)

            let views = ["bracket": bracket]
            let metrics = ["top": Layout.bigLabelTopPadding, "bottom": Layout.bracketStartY, "left": Layout.tinyWordLeftPadding, "width": totalWidth] as [String: NSNumber]

            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[bracket(width)]", options: [], metrics: metrics, views: views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[bracket]-(bottom)-|", options: [], metrics: metrics, views: views))

            brackets.append(bracket)
        }

        // refresh toolbar
        if let window = view.window, let toolbar = window.toolbar, toolbar.items.count > 1,
            let minLengthSlider = toolbar.items[0].view as? NSSlider,
            let minOccurrencesSlider = toolbar.items[1].view as? NSSlider {

            if let mostWordyPhrase = analysis.sorted(by: { $0.key.components(separatedBy: " ").count > $1.key.components(separatedBy: " ").count }).first?.key {
                let maxValue = mostWordyPhrase.components(separatedBy: " ").count
                minLengthSlider.maxValue = Double(maxValue)
                toolbar.items[0].label = "1…\(maxValue) words"
            }

            if let maxNumberOfOccurrences = analysis.sorted(by: { $0.value.count > $1.value.count }).first?.value.count {
                minOccurrencesSlider.maxValue = Double(maxNumberOfOccurrences)
                toolbar.items[1].label = "2…\(maxNumberOfOccurrences) occurrences"
            }
        }

        let requiredHeight = layOutBrackets()
        window.animator().setFrame(NSRect(origin: window.frame.origin, size: NSSize(width: totalWidth * 1.2, height: requiredHeight)), display: true)

    }

    func loadFile(from url: URL) {

        view.window?.title = url.deletingPathExtension().lastPathComponent

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
//        do {
//            let data = try JSONSerialization.data(withJSONObject: json as Any, options: .prettyPrinted)
//            try data.write(to: url)
//        } catch let e {
//            Alert(type: .fileSaveError(e)).runModal()
//        }

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

    func listenForKeyDown() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }
}

// IBOutlets
extension ViewController {

    @IBAction func showOpenPanel(_ sender: NSMenuItem? = nil) {

        // if loadedJSON is nil, show an open dialog
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.allowedFileTypes = ["json"]
        panel.directoryURL = URL(fileURLWithPath: NSString(string: "~/Developer/ComedyTokenizer/README-output.json").expandingTildeInPath, isDirectory: false)
        panel.begin { response in

            guard response == .OK else { return }

            let urls = panel.urls

            if let first = urls.first {
                self.loadFile(from: first)
            }
            if urls.count > 1 {
                for url in urls.dropFirst() {
                    let newWindow = NSWindow()
                    newWindow.contentViewController = ViewController(url: url)
                }
            }
        }
    }

    @IBAction func minCallbackLengthChanged(_ sender: NSMenuItem) {
        layOutBrackets()
    }

    @IBAction func minOccurrenceCountChanged(_ sender: NSMenuItem) {
        layOutBrackets()
    }

    @discardableResult func layOutBrackets() -> CGFloat {

        // refresh toolbar
        guard let window = view.window, let toolbar = window.toolbar, toolbar.items.count > 1,
            let minLengthSlider = toolbar.items[0].view as? NSSlider,
            let minOccurrencesSlider = toolbar.items[1].view as? NSSlider else {
                return 0
        }

        var nextLabelX: CGFloat = 0
        var nextLabelY: CGFloat = 0

        for bracket in brackets {

            let hiddenByLength = bracket.phrase.components(separatedBy: " ").count < minLengthSlider.integerValue
            let hiddenByCount =  bracket.indices.count < minOccurrencesSlider.integerValue

            bracket.isHidden = bracket.manuallyHidden || hiddenByLength || hiddenByCount

            if !bracket.isHidden {
                if nextLabelX + bracket.mainLabel.bounds.width > bracket.bounds.width {
                    nextLabelY += bracket.mainLabel.bounds.height + Layout.perMainLabelSpacing
                    nextLabelX = 0
                }
                bracket.mainLabelY = nextLabelY
                bracket.mainLabelX = nextLabelX
                nextLabelX += bracket.mainLabel.bounds.width + Layout.perMainLabelSpacing
            }
        }

        return nextLabelY * 3 // this is annoyingly arbitrary
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

    override func keyDown(with event: NSEvent) {

        if let key = event.characters, key == "x" {
            brackets.forEach {
                if $0.isSelected {
                    $0.manuallyHidden = true
//                    if var layout = json?[Keys.layout.rawValue]?[$0.phrase] as? [String: Any] {
//                        layout["hidden"] = true
//                    } else {
//                        json?[Keys.layout.rawValue]?[$0.phrase] = ["hidden": true]
//                    }
                }
            }
            layOutBrackets()
        }
    }
}
