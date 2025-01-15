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

public typealias CodableAnyClosure<T: Codable> = ((T?) -> ())
public typealias CodableArrayClosure<T: Codable> = (([T?]?) -> ())
public typealias ResponseErrorClosure = ((ResponseError?) -> ())
