//
//  WatchSessionManager.swift
//  WatchConnectivityDemo
//
//  Created by Natasha Murashev on 9/3/15.
//  Copyright © 2015 NatashaTheRobot. All rights reserved.
//

import WatchConnectivity

protocol DataSourceChangedDelegate {
    //func dataSourceDidUpdate(dataSource: DataSource)
    func messageWasReceived(dataSource: DataSource)
    func messageWasReceivedWithHandler(dataSource: DataSource, replyHandler: ([String : AnyObject]) -> Void)
}

struct DataSource {
    
    let date: SefiraDate
    
    enum SefiraDate {
        case Selected(NSDate)
        case SelectAll(Bool)
        case NeedData(Bool)
        case Unknown
    }
    
    init(data: [String : AnyObject]) {
        if let selectedDate = data["SelectedDate"] as? NSDate {
            date = SefiraDate.Selected(selectedDate)
        } else if let selectAll = data["SelectAll"] as? Bool {
            date = SefiraDate.SelectAll(selectAll)
        } else if let needsData = data["NeedData"] as? Bool {
            date = SefiraDate.NeedData(needsData)
        } else {
            date = SefiraDate.Unknown
        }
    }
}

@available(iOS 9.0, *)
class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
    private override init() {
        super.init()
    }
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    private var validSession: WCSession? {
        
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
        
        // Note: if the device is paired, but your watch app is not installed
        // consider prompting the user to install it for a better experience

        if let session = session where session.paired && session.watchAppInstalled {
            return session
        }
        return nil

    }
    
    func startSession() {
        session?.delegate = self
        session?.activateSession()
    }
    
    // keeps track of all the dataSourceChangedDelegates
    private var dataSourceChangedDelegates = [DataSourceChangedDelegate]()
    
    // adds / removes dataSourceChangedDelegates from the array
    func addDataSourceChangedDelegate<T where T: DataSourceChangedDelegate, T: Equatable>(delegate: T) {
        dataSourceChangedDelegates.append(delegate)
    }
    
    func removeDataSourceChangedDelegate<T where T: DataSourceChangedDelegate, T: Equatable>(delegate: T) {
        for (index, dataSourceDelegate) in dataSourceChangedDelegates.enumerate() {
            if let dataSourceDelegate = dataSourceDelegate as? T where dataSourceDelegate == delegate {
                dataSourceChangedDelegates.removeAtIndex(index)
                break
            }
        }
    }
}

// MARK: Application Context
// use when your app needs only the latest information
// if the data was not sent, it will be replaced
@available(iOS 9.0, *)
extension WatchSessionManager {
    
    // Sender
    func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
        if let session = validSession {
            do {
                try session.updateApplicationContext(applicationContext)
            } catch let error {
                throw error
            }
        }
    }
    
    // Receiver
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        // handle receiving application context
        
        dispatch_async(dispatch_get_main_queue()) {
            // make sure to put on the main queue to update UI!
        }
    }
}

// MARK: User Info
// use when your app needs all the data
// FIFO queue
@available(iOS 9.0, *)
extension WatchSessionManager {
    
    // Sender
    func transferUserInfo(userInfo: [String : AnyObject]) -> WCSessionUserInfoTransfer? {
        return validSession?.transferUserInfo(userInfo)
    }
    
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
        // implement this on the sender if you need to confirm that
        // the user info did in fact transfer
    }
    
    // Receiver
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        // handle receiving user info
        dispatch_async(dispatch_get_main_queue()) {
            // make sure to put on the main queue to update UI!
        }
    }
    
}

// MARK: Transfer File
@available(iOS 9.0, *)
extension WatchSessionManager {
    
    // Sender
    func transferFile(file: NSURL, metadata: [String : AnyObject]) -> WCSessionFileTransfer? {
        return validSession?.transferFile(file, metadata: metadata)
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        // handle filed transfer completion
    }
    
    // Receiver
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        // handle receiving file
        dispatch_async(dispatch_get_main_queue()) {
            // make sure to put on the main queue to update UI!
        }
    }
}


// MARK: Interactive Messaging
@available(iOS 9.0, *)
extension WatchSessionManager {
    
    // Live messaging! App has to be reachable
    private var validReachableSession: WCSession? {
        if let session = validSession where session.reachable {
            return session
        }
        return nil
    }
    
    func sessionReachabilityDidChange(session: WCSession) {
        if session.reachable {
            
        } else {
            //TODO: prompt user to unlock device
        }
    }
    
    // Sender
    func sendMessage(message: [String : AnyObject],
                     replyHandler: (([String : AnyObject]) -> Void)? = nil,
                     errorHandler: ((NSError) -> Void)? = nil)
    {
        validReachableSession?.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    func sendMessageData(data: NSData,
                         replyHandler: ((NSData) -> Void)? = nil,
                         errorHandler: ((NSError) -> Void)? = nil)
    {
        validReachableSession?.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    // Receiver
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            self.dataSourceChangedDelegates.forEach({ $0.messageWasReceivedWithHandler(DataSource(data: message), replyHandler: replyHandler) })
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            self.dataSourceChangedDelegates.forEach({ $0.messageWasReceived(DataSource(data: message)) })
        }
    }
    
    func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
        // handle receiving message data
        dispatch_async(dispatch_get_main_queue()) {
            // make sure to put on the main queue to update UI!
        }
    }
}