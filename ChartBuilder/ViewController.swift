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

    enum Examples: String {
        case readme = "~/Developer/ChartingCallbacks/README-output.json"
        case izzard1 = "~/Developer/ChartingCallbacks/data/json/Izzard-DefiniteArticle-output.json"

        var url: URL {
            return URL(fileURLWithPath: NSString(string: rawValue).expandingTildeInPath, isDirectory: false)
        }
    }

    enum ToolbarElement: Int {
        case minLengthSlider
        case minOccurrencesSlider
        case minPercentSeparationSlider
        case showHideInvisiblesButton

        func slider(in view: NSView) -> NSSlider {
            return element(in: view).view as! NSSlider
        }

        func toggle(in view: NSView) -> NSButton {
            return element(in: view).view as! NSButton
        }

        func element(in view: NSView) -> NSToolbarItem! {
            return view.window?.toolbar?.items[self.rawValue]
        }
    }

    var brackets: [BracketView] = []
    var json: [String: Any]?
    var readURL: URL?
    var hideInvisibles = true
    var fullTextCount = 0

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        readURL = Examples.readme.url
//        readURL = Examples.izzard1.url
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
        self.fullTextCount = fullText.count
        let totalWidth = Layout.totalWidth

        let fullTextLabel = TinyLabel(words: fullText, totalWidth: totalWidth)
        view.addSubview(fullTextLabel)

        let views = ["fullTextLabel": fullTextLabel]
        let metrics = ["left": Layout.tinyWordLeftPadding, "width": totalWidth] as [String: NSNumber]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[fullTextLabel(width)]", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[fullTextLabel]|", options: [], metrics: [:], views: views))

        // for each 'callback' make a selectable bracket + label
        for (index, callback) in analysis.enumerated() {

            autoreleasepool {
                let bracket = BracketView(phrase: callback.key, indices: callback.value, totalWordCount: fullText.count, color: AppColor.number(index), layout: layout?[callback.key])
                view.addSubview(bracket)

                let views = ["bracket": bracket]
                let metrics = ["top": Layout.bigLabelTopPadding, "bottom": Layout.bracketStartY, "left": Layout.tinyWordLeftPadding, "width": totalWidth] as [String: NSNumber]

                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[bracket(width)]", options: [], metrics: metrics, views: views))
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[bracket]-(bottom)-|", options: [], metrics: metrics, views: views))

                brackets.append(bracket)
            }
        }

        view.layoutSubtreeIfNeeded()

        fullTextLabel.needsLayout = true
        fullTextLabel.needsDisplay = true

        // refresh toolbar
        let minLengthSlider = ToolbarElement.minLengthSlider.slider(in: view)
        let minOccurrencesSlider = ToolbarElement.minOccurrencesSlider.slider(in: view)

        if let mostWordyPhrase = analysis.sorted(by: { $0.key.components(separatedBy: " ").count > $1.key.components(separatedBy: " ").count }).first?.key {
            let maxValue = mostWordyPhrase.components(separatedBy: " ").count
            minLengthSlider.maxValue = Double(maxValue)
            ToolbarElement.minLengthSlider.element(in: view).label = "1…\(maxValue) words"
        }

        if let maxNumberOfOccurrences = analysis.sorted(by: { $0.value.count > $1.value.count }).first?.value.count {
            minOccurrencesSlider.maxValue = Double(maxNumberOfOccurrences)
            ToolbarElement.minOccurrencesSlider.element(in: view).label = "2…\(maxNumberOfOccurrences) occurrences"
        }

        let requiredHeight = layOutBrackets()
        window.animator().setFrame(NSRect(origin: CGPoint(x: 0, y: NSScreen.main!.frame.size.height - 50), size: NSSize(width: totalWidth + Layout.tinyWordLeftPadding, height: requiredHeight)), display: true)

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

        for bracket in brackets {
            bracket.removeFromSuperview()
        }
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
        panel.directoryURL = Examples.izzard1.url
        panel.begin { response in

            guard response == .OK else { return }

            let urls = panel.urls

            if let first = urls.first {

                if first.isDirectory, let pathsInFolder = try? FileManager.default.contentsOfDirectory(atPath: first.path) {

                    for path in pathsInFolder {
                        let url = URL(fileURLWithPath: path)
                        if url.pathExtension == "json" {
                            let (wc, vc) = ViewController.newWindow(url: url)
                            wc.window?.contentViewController = vc
                            wc.window?.windowController = wc
                            wc.showWindow(wc.window)
                        }
                    }

                } else {
                    self.loadFile(from: first)
                }
            }
            if urls.count > 1 {
                for url in urls.dropFirst() {
                    let (wc, vc) = ViewController.newWindow(url: url)
                    wc.window?.contentViewController = vc
                    wc.window?.windowController = wc
                    wc.showWindow(wc.window)
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

    @IBAction func minDistancePctChanged(_ sender: NSMenuItem) {
        layOutBrackets()
    }

    @IBAction func showHideHiddenItemsSwitchChanged(_ sender: NSMenuItem) {

        let onOffSwitch = ToolbarElement.showHideInvisiblesButton.toggle(in: view)
        hideInvisibles = onOffSwitch.state == .off
        layOutBrackets()
    }

    @discardableResult func layOutBrackets() -> CGFloat {

        // refresh toolbar
        let minLength = ToolbarElement.minLengthSlider.slider(in: view).integerValue
        let minOccurrences = ToolbarElement.minOccurrencesSlider.slider(in: view).integerValue
        let minPctSeparation = ToolbarElement.minPercentSeparationSlider.slider(in: view).floatValue

        var nextLabelX: CGFloat = 0
        var nextLabelY: CGFloat = 0
        let minHeight: CGFloat = 500

        for bracket in brackets {

            let hiddenByLength = bracket.phrase.components(separatedBy: " ").count < minLength
            let hiddenByCount =  bracket.indices.count < minOccurrences

            var hiddenBySeparation = true
            if let max = bracket.indices.max(), let min = bracket.indices.min() {
                let pctSeparation = Float(max - min) / Float(fullTextCount) * 100.0
                hiddenBySeparation = pctSeparation < minPctSeparation
            }

            bracket.isHidden = (bracket.manuallyHidden && hideInvisibles) || hiddenByLength || hiddenByCount || hiddenBySeparation

            if !bracket.isHidden {
                if nextLabelX + bracket.mainLabel.bounds.width > bracket.bounds.width {
                    nextLabelY += bracket.mainLabel.bounds.height + Layout.perMainLabelSpacing
                    nextLabelX = 0
                }
                bracket.mainLabelY = nextLabelY
                bracket.mainLabelX = nextLabelX
                nextLabelX += bracket.mainLabel.bounds.width + Layout.perMainLabelSpacing

                bracket.needsLayout = true
                bracket.needsDisplay = true
            }
        }

        return nextLabelY > 0 ? nextLabelY * 4 : minHeight // this is annoyingly arbitrary
    }

    @IBAction func save(_ sender: NSMenuItem) {

        guard let readURL = readURL else { return } // todo pop save panels
        saveFile(to: readURL)
    }

    override func keyDown(with event: NSEvent) {

        if json?[Keys.layout.rawValue] == nil {
            json?[Keys.layout.rawValue] = [:]
        }

        if let key = event.characters, key == "x",
            var layouts = json?[Keys.layout.rawValue] as? [String: [String: Any]] {
            brackets.forEach {
                if $0.isSelected {
                    $0.manuallyHidden = true
                    if var layout = layouts[$0.phrase] {
                        layout["hidden"] = true
                    } else {
                        layouts[$0.phrase] = ["hidden": true]
                    }
                }
            }
            json?[Keys.layout.rawValue] = layouts
            layOutBrackets()
        }
    }

    func replaceTinyLabelsWithSnapshot(width: CGFloat) {

        view.frame = NSRect(origin: .zero, size: NSSize(width: width, height: 100))

        let bitmapRep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
        view.cacheDisplay(in: view.bounds, to: bitmapRep)
        let image = NSImage(size: view.bounds.size)
        image.addRepresentation(bitmapRep)

        let imageView = NSImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        for view in view.subviews {
            view.removeFromSuperview()
        }

        view.addSubview(imageView)

        let views = ["imageView": imageView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]", options: [], metrics: [:], views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView]|", options: [], metrics: [:], views: views))
    }

    class func newWindow(url: URL) -> (NSWindowController, ViewController) {

        let wc = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil).instantiateInitialController() as! NSWindowController
        let vc = wc.contentViewController as! ViewController

        vc.readURL = url
        vc.loadFile(from: url)
        vc.listenForKeyDown()

        return (wc, vc)
    }
}
