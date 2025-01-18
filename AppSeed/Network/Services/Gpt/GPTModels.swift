//
//  GPTModels.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

public enum GPTModel: String {
    case chat = "/chat/completions"
    case dalle = "/images/generations"
}

public enum RequestGPTSystemMessage: String {
    case empty = ""
}
