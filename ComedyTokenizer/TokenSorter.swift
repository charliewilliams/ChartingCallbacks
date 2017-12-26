//
//  Tokenizer.swift
//  ComedyTokenizer
//
//  Created by Charlie Williams on 26/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Foundation

class TokenSorter {

    typealias Progress = (String, [Int]) -> ()
    typealias Completion = ([String: [Int]]) throws -> ()
    
    let tokens: [String]
    var output: [String: [Int]] = [:]

    init(tokens: [String]) {

        self.tokens = tokens
    }

    func run(progress: @escaping Progress, completion: @escaping Completion) throws {

        var foundRepeatingToken: Bool

        repeat {

            foundRepeatingToken = false

            // For each word
            for (index, token) in tokens.enumerated() {

                // …that we haven't seen yet
                if output.keys.contains(token) {
                    continue
                }

                var out: [Int] = []

                // See how many times it appears from this point forward
                for (innerIndex, inner) in tokens.dropFirst(index).enumerated() {

                    if token == inner { // TODO make fuzzy match

                        // Write down their indices
                        out.append(innerIndex + index)
                    }
                }

                // If is appears more than once
                if out.count > 1 {

                    foundRepeatingToken = true

                    // Store it keyed on that word
                    output[token] = out

                    progress(token, out)
                }
            }

        } while foundRepeatingToken == true

        try completion(output)
    }
}
