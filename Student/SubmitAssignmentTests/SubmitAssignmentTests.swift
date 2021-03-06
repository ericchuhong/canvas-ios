//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

@testable import Core
import TestsFoundation
import XCTest
import CoreData

class SubmitAssignmentTests: XCTestCase {
    var env = TestEnvironment()
    let api = MockURLSession.self
    var database: NSPersistentContainer {
        return TestsFoundation.singleSharedTestDatabase
    }
    let uploadManager = MockUploadManager()

    override func setUp() {
        super.setUp()
        LoginSession.useTestKeychain()
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        env = TestEnvironment()
        env.database = database
        AppEnvironment.shared = env
        env.mockStore = false
        MockURLSession.reset()
        UploadManager.shared = uploadManager
        MockUploadManager.reset()
    }

    override func tearDown() {
        super.tearDown()
        LoginSession.clearAll()
    }
}
