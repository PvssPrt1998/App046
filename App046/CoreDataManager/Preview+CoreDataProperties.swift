import Foundation
import CoreData


extension Preview {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Preview> {
        return NSFetchRequest<Preview>(entityName: "Preview")
    }

    @NSManaged public var previewUrl: String
    @NSManaged public var id: Int32

}

extension Preview : Identifiable {

}
