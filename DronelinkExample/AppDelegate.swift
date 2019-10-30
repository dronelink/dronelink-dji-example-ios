//
//  AppDelegate.swift
//  DronelinkExample
//
//  Created by Jim McAndrew on 10/28/19.
//  Copyright © 2019 Dronelink. All rights reserved.
//
import DronelinkCore
import DronelinkDJI
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    internal static let droneSessionManager = DJIDroneSessionManager()
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.droneSessionManager.add(delegate: self)
        Dronelink.shared.register(environmentKey: "INSERT YOUR ENVIRONMENT KEY HERE")
        if let kernel = Bundle.main.url(forResource: "dronelink-kernel", withExtension: "js") {
            try? Dronelink.shared.install(kernel: kernel)
        }
        return true
    }
}

extension AppDelegate: DroneSessionManagerDelegate {
    func onOpened(session: DroneSession) {
        session.add(delegate: self)
    }
    
    func onClosed(session: DroneSession) {
        Dronelink.shared.announce(message: "\(session.name ?? "drone") disconnected")
    }
}

extension AppDelegate: DroneSessionDelegate {
    func onInitialized(session: DroneSession) {
        Dronelink.shared.announce(message: "\(session.name ?? "drone") connected")
    }

    func onLocated(session: DroneSession) {}

    func onMotorsChanged(session: DroneSession, value: Bool) {}

    func onCommandExecuted(session: DroneSession, command: MissionCommand) {}

    func onCommandFinished(session: DroneSession, command: MissionCommand, error: Error?) {}
}
