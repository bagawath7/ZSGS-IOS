//
//  Student+CoreDataProperties.swift
//  CoreDataProject
//
//  Created by zs-mac-4 on 14/10/22.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var name: String?
    @NSManaged public var lesson: Lesson?

}

extension Student : Identifiable {

}
