//
//  Degrees.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 29/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Foundation

postfix operator °

protocol IntegerInitializable: ExpressibleByIntegerLiteral {
    init (_: Int)
}

extension Int: IntegerInitializable {
    postfix public static func °(lhs: Int) -> CGFloat {
        return CGFloat(lhs) * .pi / 180
    }
}
