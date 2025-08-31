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
    func requestReplicate(request: RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseReplicate>)
}

final class GptService: GptServiceProtocol {
    func requestGPT(request: any RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseGPT>) {
        RequestManager.request(request, success: success)
    }
    func requestDalle(request: any RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseDALLE>) {
        RequestManager.request(request, success: success)
    }
    func requestReplicate(request: any RequestGPTProtocol, success: @escaping CodableAnyClosure<ResponseReplicate>) {
        RequestManager.request(request, success: success)
    }
}
