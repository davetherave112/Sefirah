//
//  WatchSessionManager.swift
//  WatchConnectivityDemo
//
//  Created by Natasha Murashev on 9/3/15.
//  Copyright © 2015 NatashaTheRobot. All rights reserved.
//

import WatchConnectivity

protocol DataSourceChangedDelegate {
    func dataSourceDidUpdate(_ dataSource: DataSource)
}

struct DataSource {
    
    let date: SefiraDate
    
    enum SefiraDate {
        case selected(Date)
        case deselected(Date)
        case unknown
    }
    
    init(data: [String : AnyObject]) {
        if let selectedDate = data["selected"] as? Date {
            date = SefiraDate.selected(selectedDate)
        } else if let deselectedDate = data["deselected"] as? Date {
            date = SefiraDate.deselected(deselectedDate)
        } else {
            date = SefiraDate.unknown
        }
    }
}

class WatchSessionManager: NSObject, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
    }

    
    static let sharedManager = WatchSessionManager()
    fileprivate override init() {
        super.init()
    }
    
    fileprivate let session: WCSession = WCSession.default()
    
    func startSession() {
        session.delegate = self
        session.activate()
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
extension WatchSessionManager {
    
    // Sender
    func updateApplicationContext(_ applicationContext: [String : AnyObject]) throws {
        do {
            try session.updateApplicationContext(applicationContext)
        } catch let error {
            throw error
        }
    }
    
    // Receiver
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        //dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self.dataSourceChangedDelegates.forEach { $0.dataSourceDidUpdate(DataSource(data: applicationContext as [String : AnyObject]))}
        //}
    }
}

// MARK: User Info
// use when your app needs all the data
// FIFO queue
extension WatchSessionManager {
    
    // Sender
    func transferUserInfo(_ userInfo: [String : AnyObject]) -> WCSessionUserInfoTransfer? {
        return session.transferUserInfo(userInfo)
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
extension WatchSessionManager {
    
    // Sender
    func transferFile(_ file: URL, metadata: [String : AnyObject]) -> WCSessionFileTransfer? {
        return session.transferFile(file, metadata: metadata)
    }
    
    @objc(session:didFinishFileTransfer:error:) func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        // handle filed transfer completion
    }
    
    // Receiver
    @objc(session:didReceiveFile:) func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // handle receiving file
        DispatchQueue.main.async {
            // make sure to put on the main queue to update UI!
        }
    }
}


// MARK: Interactive Messaging
extension WatchSessionManager {
    
    // Live messaging! App has to be reachable
    fileprivate var validReachableSession: WCSession? {
        if session.isReachable {
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
        validReachableSession?.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler as? ((Error) -> Void))
    }
    
    func sendMessageData(_ data: Data,
                         replyHandler: ((Data) -> Void)? = nil,
                         errorHandler: ((NSError) -> Void)? = nil)
    {
        validReachableSession?.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler as! ((Error) -> Void)?)
    }
    
    // Receiver
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        // handle receiving message
        DispatchQueue.main.async {
            // make sure to put on the main queue to update UI!
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        // handle receiving message data
        DispatchQueue.main.async {
            // make sure to put on the main queue to update UI!
        }
    }
}
