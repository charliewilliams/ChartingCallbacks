//
//  TokenizerTests.swift
//  UnitTests
//
//  Created by Charlie Williams on 26/12/2017.
//  Copyright © 2017 Charlie Williams. All rights reserved.
//

import XCTest

class TokenSorterTests: XCTestCase {

    func testMatchesAcrossCase() {

        let string = "Foo foo"

        let e = expectation(description: "Finished")

        let tokenSorter = TokenSorter(tokens: string.tokenized())
        try? tokenSorter.run(progress: { (_, _) in

        }) { (output) in
            XCTAssertEqual(output.keys.count, 1)
            e.fulfill()
        }

        wait(for: [e], timeout: 0.5)
    }

}
