//
//  main.swift
//  ComedyTokenizer
//
//  Created by Charlie Williams on 26/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

/*
 1.    Read in a big long string
 2.    Tokenize all the words
        ⁃    Store not just in a big row but as [Token: [Index]]
 3.    For each adjacent pair of tokens, look at all later occurrence indices to see if those tokens are grouped there too.
        ⁃    If you find a second occurrence of pairing, create a new "grouped" token for all of these pair-occurrences
        ⁃    Repeat this step until no more groups are created (i.e. adding a third, fourth, fifth word to the token)
 4.    Sort by token word count
 5.    Output json

 */

import Foundation

guard CommandLine.arguments.count > 1,
    let url = URL(string: (CommandLine.arguments[1] as NSString).expandingTildeInPath) else {
    fatalError("You must pass a file path to this tool")
}

print(url)

guard let data = FileManager.default.contents(atPath: url.path) else {
    fatalError("Couldn't read file at \(url.path)")
}

guard let string = String(data: data, encoding: .utf8) else {
    fatalError("Couldn't read string from file")
}

let tokens = string.tokenized()
let sorter = TokenGrouper(words: tokens)

sorter.run(progress: { (token, indices) in
    print("\"\(token)\" appeared at \(indices)")
}, completion: { output in

    let outputPath: String
    if CommandLine.arguments.count > 2 {
        outputPath = CommandLine.arguments[2]
    } else {
        outputPath = (url.path as NSString).deletingPathExtension + "-output.json"
    }

    do {
        var output = output
        output["__originalString"] = tokens
        let outputString = try JSONEncoder().encode(output)
        let outputURL = URL(fileURLWithPath: outputPath)
        try outputString.write(to: outputURL)

    } catch let e {
        fatalError(e.localizedDescription)
    }
})


