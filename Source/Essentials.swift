//   Copyright 2018 Alex Deem
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

import Foundation

public enum Result<SuccessType, ErrorType: Error> {
    //swiftlint:disable identifier_name superfluous_disable_command
    case success(SuccessType)
    case error(ErrorType)
    //swiftlint:enable identifier_name superfluous_disable_command

    public init(_ closure: () throws -> SuccessType) {
        do {
            self = .success(try closure())
        } catch let error {
            //swiftlint:disable:next force_cast
            self = .error(error as! ErrorType)
        }
    }

    public func unwrap() throws -> SuccessType {
        switch self {
        case let .success(value):
            return value
        case let .error(error):
            throw error
        }
    }
}

final public class Box<T> {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}

extension Box: Equatable where T: Equatable {
    static public func == (lhs: Box<T>, rhs: Box<T>) -> Bool {
        return lhs.value == rhs.value
    }
}

public protocol Cancellable {
    func cancel()
}
public protocol AutoCancellable: Cancellable {
    var cancelOnDeinit: Bool { get set }
}

final public class CancellableAggregator: Cancellable {
    var boxedCancellables: AtomicReference<Box<[Cancellable]?>>

    init() {
        self.boxedCancellables = AtomicReference(Box([]))
    }

    public func cancel() {
        let finalBoxedCancellables = boxedCancellables.getAndSet(newValue: Box(nil))
        guard let finalCancellables = finalBoxedCancellables.value else {
            return
        }
        for cancellable in finalCancellables {
            cancellable.cancel()
        }
    }

    public func add(_ cancellable: Cancellable) -> Bool {
        while true {
            let oldBoxedCancellables = boxedCancellables.value
            guard var newCancellables = oldBoxedCancellables.value else {
                return false
            }
            newCancellables.append(cancellable)
            if boxedCancellables.compareAndSet(expect: oldBoxedCancellables, newValue: Box(newCancellables)) {
                return true
            }
        }
    }
}

final public class AutoCancellableAggregator: AutoCancellable {
    var boxedCancellables: AtomicReference<Box<[AutoCancellable]?>>

    init() {
        self.boxedCancellables = AtomicReference(Box([]))
        self.cancelOnDeinit = true
    }

    public func cancel() {
        let finalBoxedCancellables = boxedCancellables.getAndSet(newValue: Box(nil))
        guard let finalCancellables = finalBoxedCancellables.value else {
            return
        }
        for cancellable in finalCancellables {
            cancellable.cancel()
        }
    }

    public var cancelOnDeinit: Bool {
        didSet {
            guard let currentCancellables = boxedCancellables.value.value else {
                return
            }
            for var cancellable in currentCancellables {
                cancellable.cancelOnDeinit = cancelOnDeinit
            }
        }
    }

    public func add(_ c: AutoCancellable) -> Bool {
        var cancellable = c
        cancellable.cancelOnDeinit = self.cancelOnDeinit

        while true {
            let oldBoxedCancellables = boxedCancellables.value
            guard var newCancellables = oldBoxedCancellables.value else {
                return false
            }
            newCancellables.append(cancellable)
            if boxedCancellables.compareAndSet(expect: oldBoxedCancellables, newValue: Box(newCancellables)) {
                return true
            }
        }
    }
}

final private class DispatchWorkItemCancellable: AutoCancellable {
    public var cancelOnDeinit: Bool = true
    fileprivate let workItem: DispatchWorkItem

    init(workItem: DispatchWorkItem) {
        self.workItem = workItem
    }

    deinit {
        if cancelOnDeinit {
            cancel()
        }
    }

    public func cancel() {
        self.workItem.cancel()
    }
}

extension DispatchQueue {
    public func asyncCancellable(block: @escaping () -> Void) -> AutoCancellable {
        let cancellable = DispatchWorkItemCancellable(workItem: DispatchWorkItem(block: block))
        self.async(execute: cancellable.workItem)
        return cancellable
    }
    public func asyncAfterCancellable(deadline: DispatchTime, block: @escaping () -> Void) -> AutoCancellable {
        let cancellable = DispatchWorkItemCancellable(workItem: DispatchWorkItem(block: block))
        self.asyncAfter(deadline: deadline, execute: cancellable.workItem)
        return cancellable
    }
}

final public class AtomicReference<ValueType: AnyObject> {
    private var _value: ValueType
    private let pointer: UnsafeMutablePointer<UnsafeMutableRawPointer?> = UnsafeMutablePointer.allocate(capacity: 1)

    public var value: ValueType {
        OSMemoryBarrier()
        return _value
    }

    public init(_ value: ValueType) {
        _value = value
        pointer.pointee = Unmanaged.passUnretained(_value as AnyObject).toOpaque()
    }

    deinit {
        pointer.deallocate()
    }

    public func compareAndSet(expect: ValueType, newValue: ValueType) -> Bool {
        let expectPointer = Unmanaged.passUnretained(expect as AnyObject).toOpaque()
        let newValuePointer = Unmanaged.passUnretained(newValue as AnyObject).toOpaque()

        if OSAtomicCompareAndSwapPtrBarrier(expectPointer, newValuePointer, pointer) {
            _value = newValue
            return true
        }
        return false
    }

    public func getAndSet(newValue: ValueType) -> ValueType {
        while true {
            let oldValue = self.value
            if compareAndSet(expect: oldValue, newValue: newValue) {
                return oldValue
            }
        }
    }
}

extension Dictionary {
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> [Key: T] {
        return try self.reduce(into: [Key: T](), { (result, x) in
            if let value = try transform(x.value) {
                result[x.key] = value
            }
        })
    }
}
