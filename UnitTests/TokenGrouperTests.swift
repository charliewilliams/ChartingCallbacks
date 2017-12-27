//
//  TokenizerTests.swift
//  UnitTests
//
//  Created by Charlie Williams on 26/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import XCTest

class TokenGrouperTests: XCTestCase {

    let testString = "   1.    Big long string\n2.    Tokenize all the words\n    ⁃    Store not just in a big row but as [Token: [Index]]\n3.    For each adjacent pair of tokens, look at all later occurrence indices to see if those tokens are grouped there too.\n   Big long string ⁃    If you find a second occurrence of pairing, create a new \"grouped\" token for all of these pair-occurrences ⁃    Repeat this step until no more groups are created (i.e. adding a third, fourth, fifth word to the token)\n4.  Big long string  Sort by token word count\n5.    Output json"

    func testMatchesAcrossCase() {

        let string = "Foo foo"

        let e = expectation(description: "Finished")

        let tokenSorter = TokenGrouper(words: string.tokenized())
        tokenSorter.run(progress: { (_, _) in

        }) { (output) in
            XCTAssertEqual(output.keys.count, 1)
            e.fulfill()
        }

        wait(for: [e], timeout: 0.5)
    }

    func testGroupsMultiWordPhrases() {

        let e = expectation(description: "Finished")

        let tokenSorter = TokenGrouper(words: testString.tokenized())
        tokenSorter.run(progress: { (_, _) in

        }) { (output) in
            XCTAssert(output.keys.contains { $0 == "big long string" })
            e.fulfill()
        }

        wait(for: [e], timeout: 0.5)
    }

    func testsRemovesTwoWordPhraseWithinThreeWordPhrase() {

        let e = expectation(description: "Finished")

        let tokenSorter = TokenGrouper(words: testString.tokenized())
        tokenSorter.run(progress: { (_, _) in

        }) { (output) in
            XCTAssertFalse(output.keys.contains { $0 == "big" })
            XCTAssertFalse(output.keys.contains { $0 == "long string" })
            XCTAssert(output.keys.contains { $0 == "big long string" })
            e.fulfill()
        }

        wait(for: [e], timeout: 0.5)
    }
}
