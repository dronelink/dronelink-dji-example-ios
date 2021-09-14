//
//  ViewController.swift
//  DronelinkDJIExample
//
//  Created by Jim McAndrew on 10/28/19.
//  Copyright © 2019 Dronelink. All rights reserved.
//
import DronelinkCore
import DronelinkDJI
import DronelinkCoreUI
import os
import UIKit
import DJISDK
import JavaScriptCore

class ViewController: UIViewController {
    private let log = OSLog(subsystem: "DronelinkDJIExample", category: "ViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.onDashboard(self)
        }
    }
    
    @IBAction func onDashboard(_ sender: Any) {
        loadPlan()
        //loadFunc()
        //loadMode()
        //loadScript()
    }
    
    func loadPlan() {
        guard
            let path = Bundle.main.url(forResource: "plan", withExtension: "dronelink")?.path,
            let plan = try? String(contentsOfFile: path)
        else {
            return
        }
        
        present(DashboardWidget.create(microsoftMapCredentialsKey: AppDelegate.mapCredentialsKey), animated: true) {
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
            let path = Bundle.main.url(forResource: "func", withExtension: "dronelink")?.path,
            let _func = try? String(contentsOfFile: path)
        else {
            return
        }
        
        present(DashboardWidget.create(microsoftMapCredentialsKey: AppDelegate.mapCredentialsKey), animated: true) {
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
    
    func loadMode() {
        guard
            let path = Bundle.main.url(forResource: "focus", withExtension: "dronelink")?.path,
            let mode = try? String(contentsOfFile: path)
        else {
            return
        }
        
        present(DashboardWidget.create(microsoftMapCredentialsKey: AppDelegate.mapCredentialsKey), animated: true) {
            do {
                try Dronelink.shared.load(mode: mode, delegate: self) { error in
                    os_log(.error, log: self.log, "Unable to read mode: %@", error)
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
    
    var scriptedWaypoints: [(coordinate: CLLocationCoordinate2D, altitude: Double, action: (id: String, command: String))]?
    
    func loadScript() {
        let takeoffCoordinate = CLLocationCoordinate2D(latitude: 30.26770436342115, longitude: -97.76603190710804)
        let captureAngle = -90.convertDegreesToRadians
        let pathSpeed = 5
        let approachSpeed = 10
        let photoCaptureInterval = 2
        
        guard
            let kernelURL = Bundle.main.url(forResource: "dronelink-kernel", withExtension: "js"),
            let kernel = try? String(contentsOf: kernelURL),
            let jsContext = JSContext()
        else {
            return
        }
        
        scriptedWaypoints = [
            (coordinate: CLLocationCoordinate2D(latitude: 30.267573, longitude: -97.765974), altitude: 10, action: (id: UUID().uuidString, command: "StartCaptureCameraCommand")),
            (coordinate: CLLocationCoordinate2D(latitude: 30.267904, longitude: -97.766460), altitude: 20, action: (id: UUID().uuidString, command: "StopCaptureCameraCommand")),
            (coordinate: CLLocationCoordinate2D(latitude: 30.267660, longitude: -97.766922), altitude: 30, action: (id: UUID().uuidString, command: "StartCaptureCameraCommand")),
            (coordinate: CLLocationCoordinate2D(latitude: 30.267149, longitude: -97.766779), altitude: 40, action: (id: UUID().uuidString, command: "StopCaptureCameraCommand")),
            (coordinate: CLLocationCoordinate2D(latitude: 30.267168, longitude: -97.766218), altitude: 30, action: (id: UUID().uuidString, command: "StartCaptureCameraCommand")),
            (coordinate: CLLocationCoordinate2D(latitude: 30.267493, longitude: -97.765964), altitude: 20, action: (id: UUID().uuidString, command: "StopCaptureCameraCommand"))
        ]
        
        //load the kernel so all Dronelink types are available
        jsContext.evaluateScript(kernel)
        
        //create a plan and configure a path component
        jsContext.evaluateScript("""
            //create the Plan:
            //  PlanComponent (https://github.com/dronelink/dronelink-kernel-js/blob/master/types/component/PlanComponent.d.ts)
            let plan = new Dronelink.PlanComponent()
        
            //create the context:
            //  ComponentContext (https://github.com/dronelink/dronelink-kernel-js/blob/master/types/component/ComponentContext.d.ts)
            let context = new Dronelink.ComponentContext(plan)
            
            //set the name, description, and takeoff coordinate of the plan
            plan.descriptors.name = "Example Plan"
            plan.descriptors.description = "Cool description!"
            plan.coordinate = new Dronelink.GeoCoordinate(\(takeoffCoordinate.latitude), \(takeoffCoordinate.longitude))
        
            //create the PathComponent: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/component/PathComponent.d.ts
            let component = new Dronelink.PathComponent()
            plan.rootComponent.childComponents.push(component)
                        
            //set the corning of the path component:
            //  PathCornering: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/core/Enums.d.ts
            component.cornering = Dronelink.PathCornering.Rounded
        
            //set the speed of the path component:
            //  DroneMotionComponent: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/component/DroneMotionComponent.d.ts
            //  MotionLimits6Optional: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/core/MotionLimits6Optional.d.ts
            component.droneMotionLimits.horizontal = new Dronelink.MotionLimitsOptional()
            component.droneMotionLimits.horizontal.velocity = new Dronelink.Limits(\(pathSpeed), 0)
        
            //set the approach altitude to the altitude of the first waypoint
            component.approachComponent.altitudeRange.altitude.value = \(scriptedWaypoints!.first!.altitude)
        
            //set the speed of the approach component
            component.approachComponent.droneMotionLimits.horizontal = new Dronelink.MotionLimitsOptional()
            component.approachComponent.droneMotionLimits.horizontal.velocity = new Dronelink.Limits(\(approachSpeed), 0)
        
            //set the camera up while approaching the path component
            component.approachComponent.immediateComponent = (() => {
                //create a list for the camera commands:
                //  ListComponent: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/component/ListComponent.d.ts
                const list = new Dronelink.ListComponent()

                //add an intial stop capture command via a CommandComponent (in case the camera is already started when the mission starts)
                //  StopCaptureCameraCommand: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/command/camera/StopCaptureCameraCommand.d.ts
                //  CommandComponent: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/component/CommandComponent.d.ts
                list.childComponents.push(new Dronelink.CommandComponent(new Dronelink.StopCaptureCameraCommand()))

                //set the camera mode
                //  ModeCameraCommand: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/command/camera/ModeCameraCommand.d.ts
                list.childComponents.push(
                    (() => {
                        const command = new Dronelink.ModeCameraCommand()
                        command.mode = Dronelink.CameraMode.Photo
                        return new Dronelink.CommandComponent(command)
                    })()
                )

                //set the camera photo mode to interval
                //  PhotoModeCameraCommand: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/command/camera/PhotoModeCameraCommand.d.ts
                //  CameraPhotoMode: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/core/Enums.d.ts
                list.childComponents.push(
                    (() => {
                        const command = new Dronelink.PhotoModeCameraCommand()
                        command.photoMode = Dronelink.CameraPhotoMode.Interval
                        return new Dronelink.CommandComponent(command)
                    })()
                )
        
                //set the camera photo interval
                //  PhotoIntervalCameraCommand: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/command/camera/PhotoIntervalCameraCommand.d.ts
                list.childComponents.push(
                    (() => {
                        const command = new Dronelink.PhotoModeCameraCommand()
                        command.photoInterval = \(photoCaptureInterval)
                        return new Dronelink.CommandComponent(command)
                    })()
                )

                return list
            })()
        """)
        
        //add the waypoints
        scriptedWaypoints!.enumerated().forEach { (index, waypoint) in
            jsContext.evaluateScript("""
                (() => {
                    let coordinate = new Dronelink.GeoCoordinate(\(waypoint.coordinate.latitude), \(waypoint.coordinate.longitude))
                    let offset = component.referenceCoordinate(context).offset(coordinate)
                    //if this is the first point, just use it as the approach location
                    if (\(index) === 0) {
                        component.approachComponent.destinationOffset = offset
                    } else {
                        const waypoint = new Dronelink.PathComponentWaypoint()
                        waypoint.offset = offset
                        component.addWaypoint(waypoint, context)
                    }
                })()
            """)
        }
        
        //place makers (for altitude and start / stop capture)
        jsContext.evaluateScript("const path = component.path(context)")
        scriptedWaypoints!.enumerated().forEach { (index, waypoint) in
            jsContext.evaluateScript("""
                (() => {
                    //place each marker at the nearest distance on the path to where the waypoints are
                    const marker = new Dronelink.PathComponentMarker(\(index) === 0 ? 0 : path.nearestDistance(new Dronelink.GeoCoordinate(\(waypoint.coordinate.latitude), \(waypoint.coordinate.longitude))))
                    
                    if (\(index) === 0) {
                        //gimbal pitch
                        //  Dictionary<Orientation3Optional>: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/core/Dictionary.d.ts
                        marker.gimbalOrientations = {}
                        //channel 0 (the first gimbal if multiple gimbals present, otherwise the only gimbal)
                        marker.gimbalOrientations[0] = new Dronelink.Orientation3Optional()
                        //pitch (in radians)
                        marker.gimbalOrientations[0].pitch = \(captureAngle)
                    }
            
                    //set altitude:
                    //  Altitude: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/core/Altitude.d.ts
                    marker.altitude = new Dronelink.Altitude(\(waypoint.altitude))
            
                    //add the capture command:
                    //  StartCaptureCameraCommand: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/command/camera/StartCaptureCameraCommand.d.ts
                    //  StopCaptureCameraCommand: https://github.com/dronelink/dronelink-kernel-js/blob/master/types/command/camera/StopCaptureCameraCommand.d.ts
                    marker.component = new Dronelink.CommandComponent(new Dronelink.\(waypoint.action.command)())
                    marker.component.id = '\(waypoint.action.id)'
            
                    component.addMarker(marker)
                })()
            """)
        }
        
        //serialize the plan
        guard let plan = jsContext.evaluateScript("Dronelink.Serialization.write(plan)")?.toString() else {
            return
        }
        
        present(DashboardWidget.create(microsoftMapCredentialsKey: AppDelegate.mapCredentialsKey), animated: true) {
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
}

extension ViewController: MissionExecutorDelegate {
    func missionEngageDisallowedReasons(executor: MissionExecutor) -> [Kernel.Message]? { nil }
    
    func onMissionEstimating(executor: MissionExecutor) {}
    
    func onMissionEstimated(executor: MissionExecutor, estimate: MissionExecutor.Estimate) {}
    
    func onMissionEngaging(executor: MissionExecutor) {}
    
    func onMissionEngaged(executor: MissionExecutor, engagement: MissionExecutor.Engagement) {}
    
    func onMissionExecuted(executor: MissionExecutor, engagement: MissionExecutor.Engagement) {
        guard let scriptedWaypoints = scriptedWaypoints else {
            return
        }
        
        for waypoint in scriptedWaypoints.enumerated() {
            if let state = executor.componentExecutionState(componentID: waypoint.element.action.id) {
                switch state.status {
                case .pending:
                    os_log(.debug, log: self.log, "Waypoint: %@", "\(waypoint.offset + 1)")
                    return
                    
                case .executing, .succeeded, .failed:
                    break
                    
                default:
                    break
                }
            }
        }
    }
    
    func onMissionDisengaged(executor: MissionExecutor, engagement: MissionExecutor.Engagement, reason: Kernel.Message) {
        //save mission to back-end using: executor.missionSerializedAsync
        //get asset manifest using: executor.assetManifestSerialized
        //load mission later using Dronelink.shared.load(mission: ...
    }
}

extension ViewController: FuncExecutorDelegate {
    func onFuncInputsChanged(executor: FuncExecutor) {}
    
    func onFuncExecuted(executor: FuncExecutor) {
        guard let type = executor.executableType, let executable = executor.executableSerialized else {
            return
        }
        
        do {
            switch type {
            case "Mission":
                try Dronelink.shared.load(mission: executable, delegate: self) { error in
                    os_log(.error, log: self.log, "Unable to read mission: %@", error)
                }
                break
                
            case "Mode":
                try Dronelink.shared.load(mode: executable, delegate: self) { error in
                    os_log(.error, log: self.log, "Unable to read mode: %@", error)
                }
                break
                
            default:
                break
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

extension ViewController: ModeExecutorDelegate {
    func modeEngageDisallowedReasons(executor: ModeExecutor) -> [Kernel.Message]? { nil }
    
    func onModeEngaging(executor: ModeExecutor) {}
    
    func onModeEngaged(executor: ModeExecutor, engagement: ModeExecutor.Engagement) {}
    
    func onModeExecuted(executor: ModeExecutor, engagement: ModeExecutor.Engagement) {
        
    }
    
    func onModeDisengaged(executor: ModeExecutor, engagement: ModeExecutor.Engagement, reason: Kernel.Message) {}
}
