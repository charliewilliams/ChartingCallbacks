//
//  Layout.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 29/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import AppKit

struct Layout {

    static var tinyFontSize: CGFloat { return 6 }
    static var tinyFont: NSFont { return NSFont.systemFont(ofSize: tinyFontSize) }

    static var leftMargin: CGFloat { return 0 }
    static var tinyWordHorizontalSpacing: CGFloat { return 8 }
    static var tinyWordLeftPadding: CGFloat { return 20 }
    static var tinyWordBottomPadding: CGFloat { return 0 }
    static var bracketStartY: CGFloat { return 80 }
    static var bigLabelTopPadding: CGFloat { return 60 }
    static var perMainLabelSpacing: CGFloat { return 20 }
}
