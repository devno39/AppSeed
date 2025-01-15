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
        requestAF.responseData { (response) in
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
    func requestGPT(_ request: RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseGPT>, failure: ResponseErrorClosure? = nil) {
        createRequest(request) { [weak self] data in
            guard let self else { return }
            data.responseData { (response) in
                switch response.result {
                case .success:
                    success(ResponseGPT.decode(response.value))
                case .failure:
                    self.handleError(response: response, failure: failure)
                }
            }
        }
    }
    
    //MARK: - Error Handler
    // TODO: -
    private func handleError(response: AFDataResponse<Data>, failure: ResponseErrorClosure?) {
        let error = ResponseError.decode(response.data)
        print(error?.message ?? "")
    }
}
