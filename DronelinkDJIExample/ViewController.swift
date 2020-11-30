//
//  ViewController.swift
//  DronelinkDJIExample
//
//  Created by Jim McAndrew on 10/28/19.
//  Copyright © 2019 Dronelink. All rights reserved.
//
import DronelinkCore
import DronelinkDJI
import DronelinkDJIUI
import os
import UIKit
import DJISDK

class ViewController: UIViewController {
    private let log = OSLog(subsystem: "DronelinkDJIExample", category: "ViewController")
    
    @IBAction func onDashboard(_ sender: Any) {
        loadPlan()
        //loadFunc()
    }
    
    func loadPlan() {
        guard
            let path = Bundle.main.url(forResource: "plan", withExtension: "lz")?.path,
            let plan = try? String(contentsOfFile: path)
        else {
            return
        }
        
        let dashboard = DJIDashboardViewController.create(droneSessionManager: AppDelegate.droneSessionManager, mapCredentialsKey: AppDelegate.mapCredentialsKey)
        present(dashboard, animated: true) {
            do {
                try Dronelink.shared.load(plan: plan, delegate: self) { error in
                    os_log(.error, log: self.log, "Unable to read mission plan: %@", error)
                }
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
    
    func loadFunc() {
        guard
            let path = Bundle.main.url(forResource: "func", withExtension: "lz")?.path,
            let _func = try? String(contentsOfFile: path)
        else {
            return
        }
        
        let dashboard = DJIDashboardViewController.create(droneSessionManager: AppDelegate.droneSessionManager, mapCredentialsKey: AppDelegate.mapCredentialsKey)
        present(dashboard, animated: true) {
            do {
                try Dronelink.shared.load(_func: _func, delegate: self) { error in
                    os_log(.error, log: self.log, "Unable to read function: %@", error)
                }
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
    func onMissionEstimating(executor: MissionExecutor) {}
    
    func onMissionEstimated(executor: MissionExecutor, estimate: MissionExecutor.Estimate) {}
    
    func onMissionEngaging(executor: MissionExecutor) {}
    
    func onMissionEngaged(executor: MissionExecutor, engagement: MissionExecutor.Engagement) {}
    
    func onMissionExecuted(executor: MissionExecutor, engagement: MissionExecutor.Engagement) {}
    
    func onMissionDisengaged(executor: MissionExecutor, engagement: MissionExecutor.Engagement, reason: Kernel.Message) {
        //save mission to back-end using: executor.missionSerializedAsync
        //get asset manifest using: executor.assetManifestSerialized
        //load mission later using Dronelink.shared.load(mission: ...
    }
}

extension ViewController: FuncExecutorDelegate {
    func onFuncInputsChanged(executor: FuncExecutor) {}
    
    func onFuncExecuted(executor: FuncExecutor) {
        guard let mission = executor.executableSerialized else {
            return
        }
        
        do {
            try Dronelink.shared.load(mission: mission, delegate: self) { error in
                os_log(.error, log: self.log, "Unable to read mission: %@", error)
            }
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
