//
//  RequestManager.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Foundation
import Alamofire
import JsonFellow

public class RequestManager {
    // TODO: - dont keep it here, keep it safe 🔒
    static let apiKey = ""
    
    // MARK: - Singleton
    static let shared = RequestManager()
    
    //MARK: - Create
    private func createRequest(_ request: RequestProtocol, complation: @escaping (DataRequest)-> ()) {
        let baseUrl = request is RequestGPTProtocol ? BaseUrl.gpt : BaseUrl.api
        let path = baseUrl.rawValue + request.path
        let requestAF  = AF.request(path, method: request.method, parameters: request.parameters, encoding: request.encodingType, headers: request.headers)
        
        requestAF.validate()
        LoadingHelper.shared.showLoading()
        requestAF.responseData { (response) in
            LoadingHelper.shared.hideLoading()
            complation(requestAF)
        }
    }
    
    //MARK: - Request Object
    func request<T: Codable>(_ request: RequestProtocol, success: @escaping CodableAnyClosure<T>, failure: ResponseErrorClosure? = nil) {
        createRequest(request) { [weak self] data in
            guard let self else { return }
            data.responseData { (response) in
                switch response.result {
                case .success:
                    success(T.decode(response.value))
                case .failure:
                    self.handleError(response: response, failure: failure)
                }
            }
        }
    }
    
    //MARK: - Request Array (may remove cuz request any can cover this case too)
    func request<T: Codable>(_ request: RequestProtocol, success: @escaping CodableArrayClosure<T>, failure: ResponseErrorClosure? = nil) {
        createRequest(request) { [weak self] data in
            guard let self else { return }
            data.responseData { (response) in
                switch response.result {
                case .success:
                    success([T].decode(response.value))
                case .failure:
                    self.handleError(response: response, failure: failure)
                }
            }
        }
    }
    
    // MARK: - RequestGPT
    func requestGPT<T: Codable>(_ request: RequestGPTProtocol, success: @escaping CodableAnyClosure<T>, failure: ResponseErrorGPTClosure? = nil) {
        createRequest(request) { [weak self] data in
            guard let self else { return }
            data.responseData { (response) in
                switch response.result {
                case .success:
                    success(T.decode(response.value))
                case .failure:
                    self.handleErrorGPT(response: response, failureGPT: failure)
                }
            }
        }
    }
    
    //MARK: - Error Handler
    // TODO: -
    private func handleError(response: AFDataResponse<Data>, failure: ResponseErrorClosure? = nil) {
        guard let data = response.data else { return }
        if let error = ResponseError.decode(data) {
            debugPrint("🍿 Error: \(error.message ?? "Unknown error")")
            failure?(error)
            return
        }
        
        debugPrint("🍿 Failed to decode error or no recognizable data structure")
        failure?(ResponseError(message: "An unknown error occurred"))
    }
    
    private func handleErrorGPT(response: AFDataResponse<Data>, failureGPT: ResponseErrorGPTClosure? = nil) {
        guard let data = response.data else { return }
        if let error = ResponseErrorGPT.decode(data) {
            debugPrint("🍿 ErrorGPT: \(error.error?.message ?? "Unknown error")")
            failureGPT?(error)
            return
        }
        
        debugPrint("🍿 Failed to decode error or no recognizable data structure")
        failureGPT?(ResponseErrorGPT(error: ResponseErrorGPT.Detail(message: "An unknown error occurred")))
    }
}
