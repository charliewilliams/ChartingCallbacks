//
//  StringTests.swift
//  UnitTests
//
//  Created by Charlie Williams on 26/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import XCTest

class StringTests: XCTestCase {

    func testSplitsAtSpace() {

        let string = "Foo bar"
        XCTAssertEqual(string.tokenized().count, 2)
    }

    func testDoesNotSplitAtMidWordPunctuation() {

        let string = "Foo'bar"
        XCTAssertEqual(string.tokenized().count, 1)
    }

    func testSplitsAtSentencePunctuation() {

        let string = "Foo,bar"
        XCTAssertEqual(string.tokenized().count, 2)
        let string2 = "Foo•bar"
        XCTAssertEqual(string2.tokenized().count, 2)
        let string3 = "Foo\"bar"
        XCTAssertEqual(string3.tokenized().count, 2)
    }

    func testSplitsAtLineBreak() {

        let string = "Foo\nbar"
        XCTAssertEqual(string.tokenized().count, 2)
    }

    func testSplitsOnlyOnceAtMultipleSpaces() {

        let string = "Foo  bar"
        XCTAssertEqual(string.tokenized().count, 2)
    }

    func testSplitsOnlyOnceAtMultipleLineBreaks() {

        let string = "Foo\n\nbar"
        XCTAssertEqual(string.tokenized().count, 2)
    }

    func testIgnoresCase() {

        let string = "Foo foo FOO"
        XCTAssertEqual(Set(string.tokenized()).count, 1)
    }
}
