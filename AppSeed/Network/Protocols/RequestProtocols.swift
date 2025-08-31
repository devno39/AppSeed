//
//  RequestProtocols.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Alamofire

public protocol RequestProtocol {
    var baseUrl: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get set }
    var headers: HTTPHeaders? { get set }
    var encodingType: ParameterEncoding { get set }
    var showLoading: Bool { get }
}

public protocol RequestGPTProtocol: RequestProtocol {
    var gptModel: GPTModel { get }
}
