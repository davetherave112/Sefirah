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
    
    class func createNotification(name: String, fireDate: NSDate, enabled: Bool, repeatAlert: Bool, completionHandler: (success: Bool, error: NSError?) -> ()) {
        do {
            try Notification.db.operation { (context, save) throws -> Void in
                let notificationExists: Bool = try! context.request(Notification.self).filteredWith("name", equalTo: name).fetch().count > 0
                
                if !notificationExists {
                    let newNotification: Notification = try! context.create()
                    newNotification.name = name
                    newNotification.date = fireDate
                    newNotification.enabled = true
                    newNotification.repeatAlert = repeatAlert
                    save()
                    completionHandler(success: true, error: nil)
                } else {
                    let userInfo: [NSObject : AnyObject] =
                        [
                            NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: "Please choose a different name for your notification.", comment: ""),
                            NSLocalizedFailureReasonErrorKey : NSLocalizedString("Error", value: "A notification with this name already exists.", comment: "")
                        ]
                    let error = NSError(domain: "NotificationDomain", code: 422, userInfo: userInfo)
                    completionHandler(success: false, error: error)
                }
            }
        }
        catch let error as NSError {
            completionHandler(success: false, error: error)
        }
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
