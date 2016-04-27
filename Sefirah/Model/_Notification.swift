// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Notification.swift instead.

import Foundation
import CoreData

public enum NotificationAttributes: String {
    case date = "date"
    case enabled = "enabled"
    case name = "name"
    case repeatAlert = "repeatAlert"
}

public class _Notification: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Notification"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Notification.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var date: NSDate?

    @NSManaged public
    var enabled: NSNumber?

    @NSManaged public
    var name: String?

    @NSManaged public
    var repeatAlert: NSNumber?

    // MARK: - Relationships

}

