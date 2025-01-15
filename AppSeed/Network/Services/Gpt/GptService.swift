//
//  GptService.swift
//  AppSeed
//
//  Created by tunay alver on 12.01.2025.
//

import Alamofire

protocol GptServiceProtocol {
    func postMessage(request: RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseGPT>)
}

final class GptService: RequestManager, GptServiceProtocol {
    func postMessage(request: any RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseGPT>) {
        requestGPT(request, success: success)
    }
}
