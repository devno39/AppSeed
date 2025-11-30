//
//  RequestManager+Image.swift
//  AppSeed
//
//  Created by tunay alver on 30.11.2025.
//

import Foundation
import Alamofire
import JsonFellow

extension RequestManager {
    // MARK: - Download Image
    func downloadImage(from urlString: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: urlString),
              let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            completion(nil)
            return
        }
        
        let fileURL = documentsURL.appendingPathComponent(UUID().uuidString + ".jpg")
        AF.download(url).responseData { response in
            guard let data = response.value else {
                LoadingHelper.shared.hideLoading()
                completion(nil)
                return
            }
            
            do {
                try data.write(to: fileURL)
                completion(fileURL.lastPathComponent)
            } catch {
                completion(nil)
            }
        }
    }
    
    // MARK: - Delete Image
    func deleteImage(named imageName: String) {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsURL.appendingPathComponent(imageName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                log(.success, .network, "Image deleted: \(imageName)")
            } catch {
                log(.info, .network, "Failed to delete image: \(error.localizedDescription)")
            }
        }
    }
}
