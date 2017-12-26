//
//  String.swift
//  ComedyTokenizer
//
//  Created by Charlie Williams on 26/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Foundation

extension String {

    func tokenized() -> [String] {

        let inputRange = CFRangeMake(0, count)
        let flag = UInt(kCFStringTokenizerUnitWord)
        let locale = CFLocaleCopyCurrent()
        let tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, self as CFString, inputRange, flag, locale)
        var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        var tokens: [String] = []

        while tokenType != [] {

            let currentTokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let substring = self.substring(with: currentTokenRange).lowercased()
            tokens.append(substring)
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }

        return tokens
    }

    func substring(with range: CFRange) -> String {

        let nsrange = NSMakeRange(range.location, range.length)
        return (self as NSString).substring(with: nsrange)
    }
}
