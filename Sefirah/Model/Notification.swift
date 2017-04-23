import Foundation
import SugarRecord

@objc(Notification)
open class Notification: _Notification {
	
    static var db: CoreDataDefaultStorage = {
        let store = CoreDataStore.named("db")
        let bundle = Bundle(for: Notification.classForCoder())
        let model = CoreDataObjectModel.merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }()
    
    class func fetchAllNotifications() -> [Notification] {
        let notifications: [Notification] = try! Notification.db.fetch(FetchRequest<Notification>())
        return notifications
    }
    
    class func createNotification(_ name: String, fireDate: Date, enabled: Bool, repeatAlert: Bool, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> ()) {
        do {
            try Notification.db.operation { (context, save) throws -> Void in
                let notificationExists: Bool = try! context.request(Notification.self).filtered(with: "name", equalTo: name).fetch().count > 0
                
                if !notificationExists {
                    let newNotification: Notification = try! context.create()
                    newNotification.name = name
                    newNotification.date = fireDate
                    newNotification.enabled = true
                    newNotification.repeatAlert = repeatAlert as NSNumber?
                    save()
                    completionHandler(true, nil)
                } else {
                    let userInfo: [AnyHashable: Any] =
                        [
                            NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: "Please choose a different name for your notification.", comment: ""),
                            NSLocalizedFailureReasonErrorKey : NSLocalizedString("Error", value: "A notification with this name already exists.", comment: "")
                        ]
                    let error = NSError(domain: "NotificationDomain", code: 422, userInfo: userInfo)
                    completionHandler(false, error)
                }
            }
        }
        catch let error as NSError {
            completionHandler(false, error)
        }
    }
    
    
    class func destroyExpiredNotifications() -> Bool {
        let currentDate = Date()
        let predicate: NSPredicate = NSPredicate(format: "(date < %@) AND (repeatAlert != %@)", currentDate as CVarArg, true as CVarArg)
        do {
            try Notification.db.operation { (context, save) -> Void in
                let expired: [Notification]? = try! context.request(Notification.self).filtered(with: predicate).fetch()
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
