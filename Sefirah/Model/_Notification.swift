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

open class _Notification: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Notification"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Notification.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var date: Date?

    @NSManaged open
    var enabled: NSNumber?

    @NSManaged open
    var name: String?

    @NSManaged open
    var repeatAlert: NSNumber?

    // MARK: - Relationships

}

