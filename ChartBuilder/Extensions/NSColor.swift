//
//  NSColor.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 30/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Cocoa

enum AppColor: Int {
    case gray = 0x4D4D4D
    case blue = 0x5DA5DA
    case orange = 0xFAA43A
    case green = 0x60BD68
    case pink = 0xF17CB0
    case brown = 0xB2912F
    case purple = 0xB276B2
    case yellow = 0xDECF3F
    case red = 0xF15854

    static var all: [AppColor] {
        return [.gray, .blue, .orange, .green, .pink, .brown, .purple, .yellow, .red]
    }

    static func number(_ i: Int) -> NSColor {
        return NSColor(hex: all[i % all.count].rawValue)
    }
}

extension NSColor {

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }
}
