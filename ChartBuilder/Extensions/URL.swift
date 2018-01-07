//
//  URL.swift
//  ChartBuilder
//
//  Created by Charlie Williams on 06/01/2018.
//  Copyright © 2018 Charlie Williams. All rights reserved.
//

import Foundation

extension URL {
    
    var isDirectory: Bool {
        let values = try? resourceValues(forKeys: [.isDirectoryKey])
        return values?.isDirectory ?? false
    }
}
