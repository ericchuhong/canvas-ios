//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class APIListTests: XCTestCase {
    struct Mock: Codable, Equatable {
        let list: APIList<Int>
    }

    func testSingleValue() {
        let original = Mock(list: APIList(1))
        XCTAssertEqual(original, try JSONDecoder().decode(Mock.self, from: JSONEncoder().encode(original)))
    }

    func testArray() {
        let original = Mock(list: APIList(values: [ 2, 3, 4 ]))
        XCTAssertEqual(original, try JSONDecoder().decode(Mock.self, from: JSONEncoder().encode(original)))
    }
}