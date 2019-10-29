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

import XCTest
@testable import Teacher

class StatusCellTests: TeacherTestCase {
    func testStatus() {
        let cell = StatusCell(style: .default, reuseIdentifier: nil)
        cell.status = nil
        XCTAssertNil(cell.nameLabel.text)

        cell.status = .make(attendance: nil)
        XCTAssertNil(cell.accessoryView)
        XCTAssertNotNil(cell.nameLabel.text)

        cell.status = .make(attendance: .present)
        XCTAssertEqual((cell.accessoryView as? UIImageView)?.image, Attendance.present.icon)

        cell.status = .make(student: nil, attendance: .present)
        XCTAssertEqual(cell.accessibilityLabel, " — Present")
    }
}
