//
//  ConnectivityProvider.swift
//  BonVoyageWatch Watch App
//
//  Created by Christian Romero

import WatchConnectivity

public class ConnectionProvider: ObservableObject {
    @Published public var isReady: Bool?
    @Published public var sessionReachable: Bool?
    @Published public var messageType: String?
    
    private var debbugMode: Bool = false
    
    let watchConnectivityManager: WatchConnectivityManager
    
    init(watchConnectivityManager: WatchConnectivityManager){
        self.watchConnectivityManager = watchConnectivityManager
    }
    
    public func initConn() {
        if debbugMode{
            print ("[watchos][provider] Init conn Provider")
        }
    }
    
    
    public func didIreceivedMessage(){
        
        if debbugMode{
            print("[watchos][provider] Entramos en didIreceivedMessage")
        }
        watchConnectivityManager.sessionDelegate.messageReceived = { message in
            DispatchQueue.main.async {
                //print("[watch] message \(message)")
                self.messageType = message
            }
        }
    }
    
    public func initBackgroundTask(){
        watchConnectivityManager.startBackgroundTask()
    }
    
    private var firstTime: Bool = true
    private var lastBackgroundSessionDate: Date = Date()
    
    
}

class SessionDelegate: NSObject, WCSessionDelegate {
   
    private var debbugMode: Bool = false
    
    var messageReceived: ((String) -> Void)?
    var isReady: ((Bool) -> Void)?

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
       if let error = error {
           if debbugMode{
               print("[watchos][provider] Error activating session: \(error.localizedDescription)")

           }
       } else {
           if debbugMode{
               print("[watchos][provider] Session activated")
           }
           //isReady?(true)
       }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
       if session.isReachable{
           isReady?(true)
       }else{
           isReady?(false)
       }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
       if let receivedMessage = message["message"] as? String {
           print("\(currentTime()) [watchos][provider][session diReceiveMessage] received, \(receivedMessage) \n")
           messageReceived?(receivedMessage)
       }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        if let receivedMessage = userInfo["message"] as? String {
            print("[watchos][provider][session didReceiveUserInfo]  received, \(receivedMessage) \n")
            messageReceived?(receivedMessage)
        }
    }
    
    public func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: Date())
    }
}

class WatchConnectivityManager {
    
    let sessionDelegate: SessionDelegate

    init(sessionDelegate: SessionDelegate) {
       self.sessionDelegate = sessionDelegate
       let session = WCSession.default
       session.delegate = sessionDelegate
       session.activate()
    }
    
    var dispatchWork: DispatchWorkItem?
    

    func startBackgroundTask() {
        print("[watchos][backgroundTask] Start Background TASK")
        if WCSession.default.activationState == .activated {
            WCSession.default.sendMessage([:], replyHandler: nil) { error in
                if let error = error as NSError? {
                    print("[watchos][backgroundTask] Background task error: \(error.localizedDescription)")
                } else {
                    print("[watchos][backgroundTask] Task started succesfully.")
                }
            }
            print("[watchos][backgroundTask] After ERROR.")
        } else {
            print("[watchos][backgroundTask] Watch Connectivity session is not activated.")
        }
    }
    
    public func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: Date())
    }
}

