//
//  VideoCD+CoreDataProperties.swift
//  App029
//
//  Created by Николай Щербаков on 10.03.2025.
//
//

import Foundation
import CoreData


extension VideoCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoCD> {
        return NSFetchRequest<VideoCD>(entityName: "VideoCD")
    }

    @NSManaged public var videoID: String
    @NSManaged public var url: String?
    @NSManaged public var status: String
    @NSManaged public var effect: String
    @NSManaged public var image: Data

}

extension VideoCD : Identifiable {

}
