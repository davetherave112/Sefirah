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
    func messageWasReceived(_ dataSource: DataSource)
    func messageWasReceivedWithHandler(_ dataSource: DataSource, replyHandler: ([String : AnyObject]) -> Void)
}

struct DataSource {
    
    let date: SefiraDate
    
    enum SefiraDate {
        case selected(Date)
        case selectAll(Bool)
        case needData(Bool)
        case unknown
    }
    
    init(data: [String : AnyObject]) {
        if let selectedDate = data["SelectedDate"] as? Date {
            date = SefiraDate.selected(selectedDate)
        } else if let selectAll = data["SelectAll"] as? Bool {
            date = SefiraDate.selectAll(selectAll)
        } else if let needsData = data["NeedData"] as? Bool {
            date = SefiraDate.needData(needsData)
        } else {
            date = SefiraDate.unknown
        }
    }
}

@available(iOS 9.0, *)
class WatchSessionManager: NSObject, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
    }

    public func sessionDidDeactivate(_ session: WCSession) {
        print("deactivated")
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("inactive")
    }
    
    static let sharedManager = WatchSessionManager()
    fileprivate override init() {
        super.init()
    }
    
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil
    
    fileprivate var validSession: WCSession? {
        
        // paired - the user has to have their device paired to the watch
        // watchAppInstalled - the user must have your watch app installed
        
        // Note: if the device is paired, but your watch app is not installed
        // consider prompting the user to install it for a better experience

        if let session = session , session.isPaired && session.isWatchAppInstalled {
            return session
        }
        return nil

    }
    
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    // keeps track of all the dataSourceChangedDelegates
    fileprivate var dataSourceChangedDelegates = [DataSourceChangedDelegate]()
    
    // adds / removes dataSourceChangedDelegates from the array
    func addDataSourceChangedDelegate<T>(_ delegate: T) where T: DataSourceChangedDelegate, T: Equatable {
        dataSourceChangedDelegates.append(delegate)
    }
    
    func removeDataSourceChangedDelegate<T>(_ delegate: T) where T: DataSourceChangedDelegate, T: Equatable {
        for (index, dataSourceDelegate) in dataSourceChangedDelegates.enumerated() {
            if let dataSourceDelegate = dataSourceDelegate as? T , dataSourceDelegate == delegate {
                dataSourceChangedDelegates.remove(at: index)
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
    func updateApplicationContext(_ applicationContext: [String : AnyObject]) throws {
        if let session = validSession {
            do {
                try session.updateApplicationContext(applicationContext)
            } catch let error {
                throw error
            }
        }
    }
    
    // Receiver
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // handle receiving application context
        
        DispatchQueue.main.async {
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
    func transferUserInfo(_ userInfo: [String : AnyObject]) -> WCSessionUserInfoTransfer? {
        return validSession?.transferUserInfo(userInfo)
    }
    
    @objc(session:didFinishUserInfoTransfer:error:) func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        // implement this on the sender if you need to confirm that
        // the user info did in fact transfer
    }
    
    // Receiver
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        // handle receiving user info
        DispatchQueue.main.async {
            // make sure to put on the main queue to update UI!
        }
    }
    
}

// MARK: Transfer File
@available(iOS 9.0, *)
extension WatchSessionManager {
    
    // Sender
    func transferFile(_ file: URL, metadata: [String : AnyObject]) -> WCSessionFileTransfer? {
        return validSession?.transferFile(file, metadata: metadata)
    }
    
}


// MARK: Interactive Messaging
@available(iOS 9.0, *)
extension WatchSessionManager {
    
    // Live messaging! App has to be reachable
    fileprivate var validReachableSession: WCSession? {
        if let session = validSession , session.isReachable {
            return session
        }
        return nil
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            
        } else {
            //TODO: prompt user to unlock device
        }
    }
    
    // Sender
    func sendMessage(_ message: [String : AnyObject],
                     replyHandler: (([String : Any]) -> Void)? = nil,
                     errorHandler: ((NSError) -> Void)? = nil)
    {
        validReachableSession?.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler as! ((Error) -> Void)?)
    }
    
    func sendMessageData(_ data: Data,
                         replyHandler: ((Data) -> Void)? = nil,
                         errorHandler: ((NSError) -> Void)? = nil)
    {
        validReachableSession?.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler as! ((Error) -> Void)?)
    }
    
    // Receiver
    @nonobjc func session(_ session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: @escaping ([String : AnyObject]) -> Void) {
        DispatchQueue.main.async {
            self.dataSourceChangedDelegates.forEach({ $0.messageWasReceivedWithHandler(DataSource(data: message as [String : AnyObject]), replyHandler: replyHandler) })
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.dataSourceChangedDelegates.forEach({ $0.messageWasReceived(DataSource(data: message as [String : AnyObject])) })
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        // handle receiving message data
        DispatchQueue.main.async {
            // make sure to put on the main queue to update UI!
        }
    }
}
