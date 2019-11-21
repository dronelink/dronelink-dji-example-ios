//
//  ViewController.swift
//  DronelinkDJIExample
//
//  Created by Jim McAndrew on 10/28/19.
//  Copyright © 2019 Dronelink. All rights reserved.
//
import DronelinkCore
import DronelinkDJIUI
import os
import UIKit

class ViewController: UIViewController {
    private let log = OSLog(subsystem: "DronelinkDJIExample", category: "ViewController")
    
    @IBAction func onDashboard(_ sender: Any) {
        let dashboard = DJIDashboardViewController.create(droneSessionManager: AppDelegate.droneSessionManager)
        present(dashboard, animated: true) {
            guard
                let path = Bundle.main.url(forResource: "plan", withExtension: "json")?.path,
                let plan = try? String(contentsOfFile: path)
            else {
                return
            }
            
            do {
                try Dronelink.shared.load(plan: plan, delegate: self)
            }
            catch DronelinkError.kernelUnavailable {
                os_log(.error, log: self.log, "Dronelink Kernel Unavailable")
            }
            catch DronelinkError.unregistered {
                os_log(.error, log: self.log, "Dronelink SDK Unregistered")
            }
            catch {
                os_log(.error, log: self.log, "Unknown error!")
            }
        }
    }
}

extension ViewController: MissionExecutorDelegate {
    func onMissionEstimated(executor: MissionExecutor, duration: TimeInterval) {}
    
    func onMissionEngaged(executor: MissionExecutor, engagement: MissionExecutor.Engagement) {}
    
    func onMissionExecuted(executor: MissionExecutor, engagement: MissionExecutor.Engagement) {}
    
    func onMissionDisengaged(executor: MissionExecutor, engagement: MissionExecutor.Engagement, reason: Mission.Message) {
        //save mission to back-end using: executor.missionSerialized
        //get asset manifest using: executor.assetManifestSerialized
        //load mission later using Dronelink.shared.load(mission: ...
    }
}
