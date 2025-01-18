//
//  GptService.swift
//  AppSeed
//
//  Created by tunay alver on 12.01.2025.
//

import Alamofire

protocol GptServiceProtocol {
    func requestGPT(request: RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseGPT>)
    func requestDalle(request: RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseDALLE>)
}

final class GptService: RequestManager, GptServiceProtocol {
    func requestGPT(request: any RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseGPT>) {
        requestGPT(request, success: success)
    }
    func requestDalle(request: any RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseDALLE>) {
        requestGPT(request, success: success)
    }
}
