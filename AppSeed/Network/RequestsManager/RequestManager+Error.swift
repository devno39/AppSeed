//
//  RequestManager+Error.swift
//  AppSeed
//
//  Created by tunay alver on 30.11.2025.
//

import Foundation
import Alamofire
import JsonFellow

extension RequestManager {
    enum ErrorType {
        case api, gpt
    }
    
    static func handleError(_ type: ErrorType, response: AFDataResponse<Data>, failure: ResponseErrorClosure? = nil, failureGPT: ResponseErrorGPTClosure? = nil) {
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

