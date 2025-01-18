//
//  RequestProtocols.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Alamofire

public protocol RequestProtocol {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get set }
    var headers: HTTPHeaders? { get set }
    var encodingType: ParameterEncoding { get set }
}

public protocol RequestGPTProtocol: RequestProtocol {
    var gptModel: GPTModel { get }
}
