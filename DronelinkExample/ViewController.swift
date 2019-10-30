//
//  ViewController.swift
//  DronelinkExample
//
//  Created by Jim McAndrew on 10/28/19.
//  Copyright © 2019 Dronelink. All rights reserved.
//
import DronelinkCore
import DronelinkDJIUI
import os
import UIKit

class ViewController: UIViewController {
    private let log = OSLog(subsystem: "DronelinkExample", category: "ViewController")
    
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
                try Dronelink.shared.load(plan: plan)
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

