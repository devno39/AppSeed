//
//  FirestoreHelper.swift
//  AppSeed
//
//  Created by tunay alver on 13.07.2025.
//

import FirebaseFirestore

struct FirestoreHelper {
    // MARK: - DB
    private static let db = Firestore.firestore()

    // MARK: - Generics
    static func write<T: Encodable>(to path: [String], object: T, merge: Bool = true, completion: AnyClosure<Error?>? = nil) {
        guard let data = object.toDictionary() else {
            log(.error, .firestore, "Failed to convert object to dictionary")
            completion?(NSError(domain: "FirestoreHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Encoding failed"]))
            return
        }
        write(to: path, data: data, merge: merge, completion: completion)
    }
    
    static func read<T: Decodable>(from path: [String], as type: T.Type, completion: @escaping AnyClosure<T?>) {
        read(from: path) { data in
            let model = data?.toModel(T.self)
            completion(model)
        }
    }

    // MARK: - Raws
    static func write(to path: [String], data: [String: Any], merge: Bool = true, completion: AnyClosure<Error?>? = nil) {
        guard let ref = documentRef(from: path) else {
            completion?(NSError(domain: "FirestoreHelper", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid path"]))
            return
        }

        ref.setData(data, merge: merge) { error in
            if let error = error {
                log(.error, .firestore, error.localizedDescription)
            }
            completion?(error)
        }
    }
    
    static func read(from path: [String], completion: @escaping AnyClosure<[String: Any]?>) {
        guard let ref = documentRef(from: path) else {
            completion(nil)
            return
        }

        ref.getDocument { snapshot, error in
            if let error = error {
                log(.error, .firestore, error.localizedDescription)
                completion(nil)
                return
            }

            completion(snapshot?.data())
        }
    }

    // MARK: - Document Ref Builder
    private static func documentRef(from path: [String]) -> DocumentReference? {
        guard path.count % 2 == 0 else {
            log(.error, .firestore, "Invalid path. Expected alternating collection/document")
            return nil
        }

        var current: Any = db
        for (index, component) in path.enumerated() {
            if index % 2 == 0 {
                guard let firestore = current as? Firestore else {
                    log(.error, .firestore, "Expected FirestoreReferance at index \(index), got \(type(of: current))")
                    return nil
                }
                current = firestore.collection(component)
            } else {
                guard let collection = current as? CollectionReference else {
                    log(.error, .firestore, "Expected CollectionReference at index \(index), got \(type(of: current))")
                    return nil
                }
                current = collection.document(component)
            }
        }

        return current as? DocumentReference
    }
}
