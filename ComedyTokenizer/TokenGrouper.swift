//
//  Tokenizer.swift
//  ComedyTokenizer
//
//  Created by Charlie Williams on 26/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import Foundation

class TokenGrouper {

    typealias Progress = (String, Set<Int>) -> ()
    typealias Completion = ([String: Set<Int>]) -> ()
    
    let words: [String]
    var output: [String: Set<Int>] = [:]

    init(words: [String]) {

        self.words = words
    }

    func run(progress: Progress, completion: Completion) {

        // For each word
        for (index, token) in words.enumerated() {

            // …that we haven't seen yet
            if output.keys.contains(token) {
                continue
            }

            var out: Set<Int> = []

            // See how many times it appears from this point forward
            for (innerIndex, inner) in words.dropFirst(index).enumerated() {

                if token == inner { // TODO make fuzzy match

                    // Write down their indices
                    out.insert(innerIndex + index)
                }
            }

            // If is appears more than once
            if out.count > 1 {

                // Store it keyed on that word
                output[token] = out

                progress(token, out)
            }
        }

        // Look for consecutive pairs of words who share consecutive indices; make groups of them
        for (word, indices) in output {
            forwardGroupSearch(from: word, with: indices)
        }

        completion(output)
    }

    // Group things like "covered in bees" which occur together
    func forwardGroupSearch(from word: String, with indices: Set<Int>) {

        // Look through data for all words which are one index beyond one of these indices
        // Sort them into groups
        // Add any groups where n > 1 to output

        var grouped: [String: Set<Int>] = [:]

        // Each occurrence of first word, i.e. "covered"
        for index in indices {

            // Get the next word, i.e. "in"
            guard let subsequentWordAndIndices = output.filter({ $1.contains(index + 1) }).first else {
                continue
            }

            // Make the combined phrase
            let combinedKey = "\(word) \(subsequentWordAndIndices.key)"

            // See which indices hold the combined phrases
            for subsequentIndex in subsequentWordAndIndices.value {

                // And store them
                if indices.contains(subsequentIndex - 1) {
                    if grouped[combinedKey] != nil {
                        grouped[combinedKey]?.insert(index)
                    } else {
                        grouped[combinedKey] = [index]
                    }
                }
            }
        }

        // Add grouped to output?
        for (phrase, indices) in grouped {

            if indices.count > 1 {
                output[phrase] = indices
            }
        }
    }
}
