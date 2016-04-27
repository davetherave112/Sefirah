import Foundation
import CoreData
import SugarRecord

@objc(Notification)
public class Notification: _Notification {
	
    static var db: CoreDataDefaultStorage = {
        let store = CoreData.Store.Named("db")
        let bundle = NSBundle(forClass: Notification.classForCoder())
        let model = CoreData.ObjectModel.Merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }()
    
    class func fetchAllNotifications() -> [Notification] {
        let notifications: [Notification] = try! Notification.db.fetch(Request<Notification>())
        return notifications
    }
    
    
    
    class func destroyExpiredNotifications() -> Bool {
        let currentDate = NSDate()
        let predicate: NSPredicate = NSPredicate(format: "(date < %@) AND (repeatAlert != %@)", currentDate, true)
        do {
            try Notification.db.operation { (context, save) -> Void in
                let expired: [Notification]? = try! context.request(Notification.self).filteredWith(predicate: predicate).fetch()
                if let expired = expired {
                    try! context.remove(expired)
                    save()
                }
            }
            return true
        }
        catch {
            return false
            // There was an error in the operation
        }
    }
}
