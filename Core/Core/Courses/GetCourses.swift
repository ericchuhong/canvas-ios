//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation

public class GetCourses: CollectionUseCase {
    public typealias Model = Course

    let showFavorites: Bool
    let enrollmentState: GetCoursesRequest.EnrollmentState?
    let perPage: Int

    public var scope: Scope {
        let order = [
            NSSortDescriptor(key: #keyPath(Course.name), ascending: true, naturally: true),
            NSSortDescriptor(key: #keyPath(Course.id), ascending: true),
        ]
        let predicate: NSPredicate
        if showFavorites {
            predicate = NSPredicate(key: #keyPath(Course.isFavorite), equals: true)
        } else if let enrollmentState = enrollmentState {
            predicate = NSPredicate(format: "ANY %K == %@", #keyPath(Course.enrollments.stateRaw), enrollmentState.rawValue)
        } else {
            predicate = .all
        }
        return Scope(predicate: predicate, order: order)
    }

    public var request: GetCoursesRequest {
        return GetCoursesRequest(enrollmentState: enrollmentState, perPage: perPage)
    }

    public var cacheKey: String? {
        if let enrollmentState = enrollmentState {
            return "get-courses-\(enrollmentState)"
        }
        return "get-courses"
    }

    public init(showFavorites: Bool = false, enrollmentState: GetCoursesRequest.EnrollmentState? = .active, perPage: Int = 10) {
        self.showFavorites = showFavorites
        self.enrollmentState = enrollmentState
        self.perPage = perPage
    }
}

public class GetAllCourses: CollectionUseCase {
    public typealias Model = Course

    public let cacheKey: String? = "courses"

    public var request: GetCoursesRequest {
        return GetCoursesRequest(enrollmentState: nil, state: [ .available, .completed ], perPage: 100)
    }

    public let scope = Scope(predicate: .all, order: [
        NSSortDescriptor(key: #keyPath(Course.isPastEnrollment), ascending: true),
        NSSortDescriptor(key: #keyPath(Course.name), ascending: true, naturally: true),
        NSSortDescriptor(key: #keyPath(Course.id), ascending: true),
    ], sectionNameKeyPath: #keyPath(Course.isPastEnrollment))

    public init() {}
}
