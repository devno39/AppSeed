//
//  TrackingHelper.swift
//  AppSeed
//
//  Created by tunay alver on 13.07.2025.
//

import AppTrackingTransparency
import AdSupport

enum TrackingHelper {
    static func requestTrackingAuthorization(completion: EmptyClosure? = nil) {
        let status = ATTrackingManager.trackingAuthorizationStatus
        switch status {
        case .notDetermined:
            ATTrackingManager.requestTrackingAuthorization { newStatus in
                DispatchQueue.main.async {
                    self.logTrackingStatus(newStatus)
                    completion?()
                }
            }
        default:
            logTrackingStatus(status)
            completion?()
        }
    }

    private static func logTrackingStatus(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            log(.info, .tracking, "Takip izni verildi — IDFA: \(idfa)")
        case .denied:
            log(.info, .tracking, "Takip izni reddedildi — Ayarlar'dan açılmalı")
        case .restricted:
            log(.info, .tracking, "Takip izni kısıtlı (örneğin Ebeveyn Denetimi)")
        case .notDetermined:
            log(.info, .tracking, "Takip izni hala notDetermined")
        @unknown default:
            log(.info, .tracking, "Bilinmeyen izleme durumu")
        }
    }
}
