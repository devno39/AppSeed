//
//  Typealias.swift
//  AppSeed
//
//  Created by tunay alver on 9.08.2023.
//

import Foundation

public typealias EmptyClosure = () -> Void
public typealias AnyClosure<T> = (T) -> Void
public typealias OptinalAnyClosure<T> = (T?) -> Void

public typealias CodableAnyClosure<T: Codable> = ((T?) -> Void)
public typealias CodableArrayClosure<T: Codable> = (([T?]?) -> Void)
public typealias ResponseErrorClosure = ((ResponseError?) -> Void)
public typealias ResponseErrorGPTClosure = ((ResponseErrorGPT?) -> Void)
