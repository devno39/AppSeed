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
}
