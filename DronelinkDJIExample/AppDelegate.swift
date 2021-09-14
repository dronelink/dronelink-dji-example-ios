//
//  AppDelegate.swift
//  DronelinkDJIExample
//
//  Created by Jim McAndrew on 10/28/19.
//  Copyright © 2019 Dronelink. All rights reserved.
//
import DronelinkCore
import DronelinkDJI
import UIKit
import os

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let log = OSLog(subsystem: "DronelinkDJIExample", category: "AppDelegate")
    
    internal static let mapCredentialsKey = "INSERT YOUR CREDENTIALS KEY HERE"

    var window: UIWindow?
    
    var assetManifest: AssetManifest?
    var assetIndex: Int?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Dronelink.shared.add(delegate: self)
        Dronelink.shared.register(environmentKey: "INSERT YOUR ENVIRONMENT KEY HERE")
        Dronelink.shared.add(droneSessionManager: DJIDroneSessionManager())
        do {
            //use Dronelink.KernelVersionTarget to see the minimum compatible kernel version that the current core supports
            try Dronelink.shared.install(kernel: Bundle.main.url(forResource: "dronelink-kernel", withExtension: "js")!)
            assetManifest = try? Dronelink.shared.createAssetManifest(id: "example", tags: ["tag1", "tag2"])
            assetIndex = assetManifest?.addAsset(key: "key", descriptors: Kernel.Descriptors(name: "name", description: "description", tags: ["tag1", "tag2"]))
        }
        catch DronelinkError.kernelInvalid {
            os_log(.error, log: self.log, "Dronelink Kernel Invalid")
        }
        catch DronelinkError.kernelIncompatible {
            os_log(.error, log: self.log, "Dronelink Kernel Incompatible")
        }
        catch {
            os_log(.error, log: self.log, "Unknown error!")
        }
        
        return true
    }
}

extension AppDelegate: DronelinkDelegate {
    func onRegistered(error: String?) {}
    
    func onDroneSessionManagerAdded(manager: DroneSessionManager) {
        manager.add(delegate: self)
    }
    
    func onMissionLoaded(executor: MissionExecutor) {}
    
    func onMissionUnloaded(executor: MissionExecutor) {}
    
    func onFuncLoaded(executor: FuncExecutor) {}
    
    func onFuncUnloaded(executor: FuncExecutor) {}
    
    func onModeLoaded(executor: ModeExecutor) {}
    
    func onModeUnloaded(executor: ModeExecutor) {}
    
    func onCameraFocusCalibrationRequested(value: Kernel.CameraFocusCalibration) {}
    
    func onCameraFocusCalibrationUpdated(value: Kernel.CameraFocusCalibration) {}
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

    func onCommandExecuted(session: DroneSession, command: KernelCommand) {}

    func onCommandFinished(session: DroneSession, command: KernelCommand, error: Error?) {}
    
    func onCameraFileGenerated(session: DroneSession, file: CameraFile) {
        assetManifest?.addCameraFile(assetIndex: assetIndex ?? 0, cameraFile: file)
        //assetManifest?.serialized to get the manually tracked asset manifest json
    }
}
