//
//  RequestManager.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Foundation
import Alamofire
import JsonFellow

public final class RequestManager {
    //MARK: - Create
    private static func createRequest(_ request: RequestProtocol, completion: @escaping (AFDataResponse<Data>) -> Void) {
        let path = request.baseUrl + request.path
        let af = AF.request(
            path,
            method: request.method,
            parameters: request.parameters,
            encoding: request.encodingType,
            headers: request.headers
        )
        
        if request.showLoading { LoadingHelper.shared.showLoading() }
        
        af.validate().responseData { response in
            if request.showLoading { LoadingHelper.shared.hideLoading() }
            completion(response)
        }
    }
    
    //MARK: - Request Object
    static func request<T: Codable>(_ request: RequestProtocol, success: @escaping CodableAnyClosure<T>, failure: ResponseErrorClosure? = nil, failureGPT: ResponseErrorGPTClosure? = nil) {
        createRequest(request) { response in
            switch response.result {
            case .success:
                success(T.decode(response.value))
            case .failure:
                if request is RequestGPTProtocol {
                    self.handleError(.gpt, response: response, failureGPT: failureGPT)
                } else {
                    self.handleError(.api, response: response, failure: failure)
                }
            }
        }
    }
    
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

//MARK: - Error
extension RequestManager {
    enum ErrorType {
        case api, gpt
    }
    
    private static func handleError(_ type: ErrorType, response: AFDataResponse<Data>, failure: ResponseErrorClosure? = nil, failureGPT: ResponseErrorGPTClosure? = nil) {
        switch type {
        case .api:
            handleErrorRequest(response: response, failure: failure)
        case .gpt:
            handleErrorGPT(response: response, failureGPT: failureGPT)
        }
    }
    
    private static func handleErrorRequest(response: AFDataResponse<Data>, failure: ResponseErrorClosure? = nil) {
        guard let data = response.data else { return }
        if let error = ResponseError.decode(data) {
            log(.error, .network, "Error: \(error.message ?? "Unknown error")")
            failure?(error)
            return
        }
        
        log(.error, .network, "Failed to decode error or no recognizable data structure")
        failure?(ResponseError(message: "An unknown error occurred"))
    }
    
    private static func handleErrorGPT(response: AFDataResponse<Data>, failureGPT: ResponseErrorGPTClosure? = nil) {
        guard let data = response.data else { return }
        if let error = ResponseErrorGPT.decode(data) {
            log(.error, .network, "ErrorGPT: \(error.error?.message ?? "Unknown error")")
            failureGPT?(error)
            return
        }
        
        log(.error, .network, "Failed to decode error or no recognizable data structure")
        failureGPT?(ResponseErrorGPT(error: ResponseErrorGPT.Detail(message: "An unknown error occurred")))
    }
}
