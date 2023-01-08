//
//  TCArrayPointer.swift
//  
//
//  Created by Yehor Popovych on 07.05.2021.
//

import Foundation

public struct TCArrayPointer1<A1, E1> {
    public func wrap<R>(
        _ a1: inout A1,
        _ cb: (UnsafeMutableBufferPointer<E1>) throws -> R) rethrows -> R
    {
        try withUnsafeMutableBytes(of: &a1) { p1 in
            try cb(p1.bindMemory(to: E1.self))
        }
    }
    
    public func wrap<R>(
        _ a1: A1,
        _ cb: (UnsafeBufferPointer<E1>) throws -> R) rethrows -> R
    {
        try withUnsafeBytes(of: a1) { p1 in
            try cb(p1.bindMemory(to: E1.self))
        }
    }
}


public struct TCArrayPointer2<A1, E1, A2, E2> {
    public func wrap<R>(
        _ a1: inout A1,
        _ a2: inout A2,
        _ cb: (UnsafeMutableBufferPointer<E1>,
               UnsafeMutableBufferPointer<E2>) throws -> R) rethrows -> R
    {
        try withUnsafeMutableBytes(of: &a1) { p1 in
            try withUnsafeMutableBytes(of: &a2) { p2 in
                try cb(
                    p1.bindMemory(to: E1.self),
                    p2.bindMemory(to: E2.self)
                )
            }
        }
    }
    
    public func wrap<R>(
        _ a1: inout A1,
        _ a2: A2,
        _ cb: (UnsafeMutableBufferPointer<E1>,
               UnsafeBufferPointer<E2>) throws -> R) rethrows -> R
    {
        try withUnsafeMutableBytes(of: &a1) { p1 in
            try withUnsafeBytes(of: a2) { p2 in
                try cb(
                    p1.bindMemory(to: E1.self),
                    p2.bindMemory(to: E2.self)
                )
            }
        }
    }
    
    public func wrap<R>(
        _ a1: A1,
        _ a2: A2,
        _ cb: (UnsafeBufferPointer<E1>,
               UnsafeBufferPointer<E2>) throws -> R) rethrows -> R
    {
        try withUnsafeBytes(of: a1) { p1 in
            try withUnsafeBytes(of: a2) { p2 in
                try cb(
                    p1.bindMemory(to: E1.self),
                    p2.bindMemory(to: E2.self)
                )
            }
        }
    }
}

public struct TCArrayPointer3<A1, E1, A2, E2, A3, E3> {
    public func wrap<R>(
        _ a1: inout A1,
        _ a2: inout A2,
        _ a3: inout A3,
        _ cb: (UnsafeMutableBufferPointer<E1>,
               UnsafeMutableBufferPointer<E2>,
               UnsafeMutableBufferPointer<E3>) throws -> R) rethrows -> R
    {
        try withUnsafeMutableBytes(of: &a1) { p1 in
            try withUnsafeMutableBytes(of: &a2) { p2 in
                try withUnsafeMutableBytes(of: &a3) { p3 in
                    try cb(
                        p1.bindMemory(to: E1.self),
                        p2.bindMemory(to: E2.self),
                        p3.bindMemory(to: E3.self)
                    )
                }
            }
        }
    }
    
    public func wrap<R>(
        _ a1: inout A1,
        _ a2: inout A2,
        _ a3: A3,
        _ cb: (UnsafeMutableBufferPointer<E1>,
               UnsafeMutableBufferPointer<E2>,
               UnsafeBufferPointer<E3>) throws -> R) rethrows -> R
    {
        try withUnsafeMutableBytes(of: &a1) { p1 in
            try withUnsafeMutableBytes(of: &a2) { p2 in
                try withUnsafeBytes(of: a3) { p3 in
                    try cb(
                        p1.bindMemory(to: E1.self),
                        p2.bindMemory(to: E2.self),
                        p3.bindMemory(to: E3.self)
                    )
                }
            }
        }
    }
    
    public func wrap<R>(
        _ a1: inout A1,
        _ a2: A2,
        _ a3: A3,
        _ cb: (UnsafeMutableBufferPointer<E1>,
               UnsafeBufferPointer<E2>,
               UnsafeBufferPointer<E3>) throws -> R) rethrows -> R
    {
        try withUnsafeMutableBytes(of: &a1) { p1 in
            try withUnsafeBytes(of: a2) { p2 in
                try withUnsafeBytes(of: a3) { p3 in
                    try cb(
                        p1.bindMemory(to: E1.self),
                        p2.bindMemory(to: E2.self),
                        p3.bindMemory(to: E3.self)
                    )
                }
            }
        }
    }
    
    public func wrap<R>(
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ cb: (UnsafeBufferPointer<E1>,
               UnsafeBufferPointer<E2>,
               UnsafeBufferPointer<E3>) throws -> R) rethrows -> R
    {
        try withUnsafeBytes(of: a1) { p1 in
            try withUnsafeBytes(of: a2) { p2 in
                try withUnsafeBytes(of: a3) { p3 in
                    try cb(
                        p1.bindMemory(to: E1.self),
                        p2.bindMemory(to: E2.self),
                        p3.bindMemory(to: E3.self)
                    )
                }
            }
        }
    }
}

public struct TCArrayPointer4<A1, E1, A2, E2, A3, E3, A4, E4> {
    public func wrap<R>(
        _ a1: inout A1,
        _ a2: inout A2,
        _ a3: inout A3,
        _ a4: inout A4,
        _ cb: (UnsafeMutableBufferPointer<E1>,
               UnsafeMutableBufferPointer<E2>,
               UnsafeMutableBufferPointer<E3>,
               UnsafeMutableBufferPointer<E4>) throws -> R) rethrows -> R
    {
        try withUnsafeMutableBytes(of: &a1) { p1 in
            try withUnsafeMutableBytes(of: &a2) { p2 in
                try withUnsafeMutableBytes(of: &a3) { p3 in
                    try withUnsafeMutableBytes(of: &a4) { p4 in
                        try cb(
                            p1.bindMemory(to: E1.self),
                            p2.bindMemory(to: E2.self),
                            p3.bindMemory(to: E3.self),
                            p4.bindMemory(to: E4.self)
                        )
                    }
                }
            }
        }
    }
    
    public func wrap<R>(
        _ a1: inout A1,
        _ a2: inout A2,
        _ a3: inout A3,
        _ a4: A4,
        _ cb: (UnsafeMutableBufferPointer<E1>,
               UnsafeMutableBufferPointer<E2>,
               UnsafeMutableBufferPointer<E3>,
               UnsafeBufferPointer<E4>) throws -> R) rethrows -> R
    {
        try withUnsafeMutableBytes(of: &a1) { p1 in
            try withUnsafeMutableBytes(of: &a2) { p2 in
                try withUnsafeMutableBytes(of: &a3) { p3 in
                    try withUnsafeBytes(of: a4) { p4 in
                        try cb(
                            p1.bindMemory(to: E1.self),
                            p2.bindMemory(to: E2.self),
                            p3.bindMemory(to: E3.self),
                            p4.bindMemory(to: E4.self)
                        )
                    }
                }
            }
        }
    }
    
    public func wrap<R>(
        _ a1: inout A1,
        _ a2: inout A2,
        _ a3: A3,
        _ a4: A4,
        _ cb: (UnsafeMutableBufferPointer<E1>,
               UnsafeMutableBufferPointer<E2>,
               UnsafeBufferPointer<E3>,
               UnsafeBufferPointer<E4>) throws -> R) rethrows -> R
    {
        try withUnsafeMutableBytes(of: &a1) { p1 in
            try withUnsafeMutableBytes(of: &a2) { p2 in
                try withUnsafeBytes(of: a3) { p3 in
                    try withUnsafeBytes(of: a4) { p4 in
                        try cb(
                            p1.bindMemory(to: E1.self),
                            p2.bindMemory(to: E2.self),
                            p3.bindMemory(to: E3.self),
                            p4.bindMemory(to: E4.self)
                        )
                    }
                }
            }
        }
    }
    
    public func wrap<R>(
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4,
        _ cb: (UnsafeBufferPointer<E1>,
               UnsafeBufferPointer<E2>,
               UnsafeBufferPointer<E3>,
               UnsafeBufferPointer<E4>) throws -> R) rethrows -> R
    {
        try withUnsafeBytes(of: a1) { p1 in
            try withUnsafeBytes(of: a2) { p2 in
                try withUnsafeBytes(of: a3) { p3 in
                    try withUnsafeBytes(of: a4) { p4 in
                        try cb(
                            p1.bindMemory(to: E1.self),
                            p2.bindMemory(to: E2.self),
                            p3.bindMemory(to: E3.self),
                            p4.bindMemory(to: E4.self)
                        )
                    }
                }
            }
        }
    }
}
