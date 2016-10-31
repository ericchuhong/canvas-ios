//
//  Courses.swift
//  Airwolf
//
//  Created by Ben Kraus on 5/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import SoPersistent
import ReactiveCocoa
import Marshal
import EnrollmentKit

extension Course {
    public static func predicate(courseID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", courseID)
    }
    
    public static func getCoursesFromAirwolf(session: Session, studentID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/courses", parameters: Course.getCoursesParameters)
        return session.paginatedJSONSignalProducer(request)
            
            // filter out restricted courses because their json is too sparse and will cause parsing issues
            .map { coursesJSON in
                return coursesJSON.filter { json in
                    let restricted: Bool = (try? json <| "access_restricted_by_date") ?? false
                    return !restricted
                }
        }
    }
    
    public static func getCourseFromAirwolf(session: Session, studentID: String, courseID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/courses/\(courseID)", parameters: Course.getCourseParameters)
        return session.JSONSignalProducer(request)
    }
    
    public static func airwolfCollectionRefresher(session: Session, studentID: String) throws -> Refresher {
        let remote = try Course.getCoursesFromAirwolf(session, studentID: studentID)
        let context = try session.enrollmentManagedObjectContext(studentID)
        
        let sync = Course.syncSignalProducer(inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [studentID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
    
    public static func airwolfRefresher(session: Session, studentID: String, courseID: String) throws -> Refresher {
        let remote = try Course.getCourseFromAirwolf(session, studentID: studentID, courseID: courseID).map { [$0] }
        let context = try session.enrollmentManagedObjectContext(studentID)
        let predicate = Course.predicate(courseID)
        
        let sync = Course.syncSignalProducer(predicate, inContext: context, fetchRemote: remote)
        
        let key = cacheKey(context, [studentID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}

