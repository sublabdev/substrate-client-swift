//
//  TCArray.swift
//  
//
//  Created by Yehor Popovych on 07.05.2021.
//

import Foundation

public struct TCArray {
    private init() {}
    
    public enum Error: Swift.Error {
        case sizeMismatch(got: Int, size: Int)
        case elementSizeMismatch
    }
    
    public static func new<A>() -> A {
        try! new(raw: Data(repeating: 0, count:  MemoryLayout<A>.size))
    }
    
    public static func new<A>(raw: Data) throws -> A {
        guard raw.count == MemoryLayout<A>.size else {
            throw Error.sizeMismatch(got: raw.count, size: MemoryLayout<A>.size)
        }
        return raw.withUnsafeBytes { rawPtr in
            rawPtr.bindMemory(to: A.self).baseAddress!.pointee
        }
    }
    
    public static func new<A, E>(values: [E]) throws -> A {
        let elSize = MemoryLayout<E>.stride
        let arrSize = MemoryLayout<A>.size
        guard arrSize % elSize == 0 else {
            throw Error.elementSizeMismatch
        }
        guard arrSize / elSize == values.count else {
            throw Error.sizeMismatch(got: values.count, size: arrSize / elSize)
        }
        return values.withUnsafeBytes { ptr in
            ptr.bindMemory(to: A.self).baseAddress!.pointee
        }
    }
    
    public static func get<A>(raw array: A) -> Data {
        withUnsafeBytes(of: array) { rawPtr in
            return Data(rawPtr)
        }
    }
    
    public static func get<A, E>(values array: A) throws -> [E] {
        try get(values: array, of: E.self)
    }
    
    public static func get<A, E>(values array: A, of element: E.Type) throws -> [E] {
        let elSize = MemoryLayout<E>.stride
        return try withUnsafeBytes(of: array) { rawPtr in
            guard rawPtr.count % elSize == 0 else {
                throw Error.elementSizeMismatch
            }
            return Array(rawPtr.bindMemory(to: element))
        }
    }
    
    public static func set<A>(_ array: inout A, raw: Data) throws {
        let _ = try withUnsafeMutableBytes(of: &array) { rawPtr in
            guard rawPtr.count == raw.count else {
                throw Error.sizeMismatch(got: raw.count, size: rawPtr.count)
            }
            raw.copyBytes(to: rawPtr)
        }
    }
    
    public static func set<A, E>(_ array: inout A, values: [E]) throws {
        let elSize = MemoryLayout<E>.stride
        try withUnsafeMutableBytes(of: &array) { rawPtr in
            guard rawPtr.count % elSize == 0 else {
                throw Error.elementSizeMismatch
            }
            guard values.count == rawPtr.count / elSize else {
                throw Error.sizeMismatch(
                    got: values.count, size: rawPtr.count / elSize
                )
            }
            let elPtr = rawPtr.baseAddress!.assumingMemoryBound(to: E.self)
            elPtr.assign(from: values, count: values.count)
        }
    }
    
    public static func equal<A>(_ a1: A, _ a2: A) -> Bool {
        withUnsafeBytes(of: a1) { p1 in
            withUnsafeBytes(of: a2) { p2 in
                guard p1.count == p2.count else { return false }
                return memcmp(p1.baseAddress!, p2.baseAddress!, p1.count) == 0
            }
        }
    }
    
    public static func hash<A>(_ array: A, in hasher: inout Hasher) {
        withUnsafeBytes(of: array) { ptr in
            hasher.combine(bytes: ptr)
        }
    }
}


extension TCArray /* Pointers */ {
    public static func pointer<E1, A1>(
        of: E1.Type
    ) -> TCArrayPointer1<A1, E1> {
        TCArrayPointer1()
    }
    
    public static func pointer<E1, E2, A1, A2>(
        of: (E1.Type, E2.Type)
    ) -> TCArrayPointer2<A1, E1, A2, E2> {
        TCArrayPointer2()
    }
    
    public static func pointer<E1, E2, E3, A1, A2, A3>(
        of: (E1.Type, E2.Type, E3.Type)
    ) -> TCArrayPointer3<A1, E1, A2, E2, A3, E3> {
        TCArrayPointer3()
    }
    
    public static func pointer<E1, E2, E3, E4, A1, A2, A3, A4>(
        of: (E1.Type, E2.Type, E3.Type, E4.Type)
    ) -> TCArrayPointer4<A1, E1, A2, E2, A3, E3, A4, E4> {
        TCArrayPointer4()
    }
}
