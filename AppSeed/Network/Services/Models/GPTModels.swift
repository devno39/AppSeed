//
//  GPTModels.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

public enum GPTModel: String {
    // gpt
    case chat = "/chat/completions"
    case dalle = "/images/generations"
    
    // replicate flux
    case flux_schnell = "/models/black-forest-labs/flux-schnell/predictions"
    
    // flux
    case falai_flux_dev = "/fal-ai/flux/dev"
    case falai_flux_requests = "/fal-ai/flux/requests"
    
    // nano-banana
    case falai_nano_banana = "/fal-ai/nano-banana"
    case falai_nano_banana_requests = "/fal-ai/nano-banana/requests"
}

public enum RequestGPTSystemMessage: String {
    case empty = ""
}
