//
//  PermissionManager.swift
//  AppSeed
//
//  Created by Claude on 25.03.2026.
//

import Foundation
import UIKit
import CoreLocation
import UserNotifications
import Photos

// MARK: - Permission Type
enum PermissionType: CaseIterable {
    case location
    case notification
    case photos
}

// MARK: - Notification
extension Notification.Name {
    static let permissionsDidChange = Notification.Name("permissionsDidChange")
}

// MARK: - PermissionManager
final class PermissionManager: NSObject {
    static let shared = PermissionManager()

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var notificationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Status
    var allGranted: Bool {
        pendingPermissions.isEmpty
    }

    var pendingPermissions: [PermissionType] {
        PermissionType.allCases.filter { !isGranted($0) }
    }

    func isGranted(_ type: PermissionType) -> Bool {
        switch type {
        case .location:
            let status = locationManager.authorizationStatus
            return status == .authorizedWhenInUse || status == .authorizedAlways
        case .notification:
            return notificationStatus == .authorized
        case .photos:
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            return status == .authorized || status == .limited
        }
    }

    func isDenied(_ type: PermissionType) -> Bool {
        switch type {
        case .location:
            return locationManager.authorizationStatus == .denied
        case .notification:
            return notificationStatus == .denied
        case .photos:
            return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .denied
        }
    }

    // MARK: - Photo Permission
    func requestPhotosPermission(completion: @escaping BoolClosure) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }

    // MARK: - Unified Request
    // iOS swallows request* once .denied — route to Settings instead.
    func requestOrOpenSettings(_ type: PermissionType) {
        if isDenied(type) {
            openAppSettings()
            return
        }
        switch type {
        case .location:
            locationManager.requestWhenInUseAuthorization()
        case .notification:
            NotificationHelper.requestAuthorization { [weak self] _ in
                self?.notifyChange()
            }
        case .photos:
            requestPhotosPermission { [weak self] _ in
                self?.notifyChange()
            }
        }
    }

    private func openAppSettings() {
        DispatchQueue.main.async {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Refresh
    func refreshNotificationStatus(completion: EmptyClosure? = nil) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.notificationStatus = settings.authorizationStatus
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    // MARK: - Notify
    func notifyChange() {
        refreshNotificationStatus {
            NotificationCenter.default.post(name: .permissionsDidChange, object: nil)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension PermissionManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        notifyChange()
    }
}
