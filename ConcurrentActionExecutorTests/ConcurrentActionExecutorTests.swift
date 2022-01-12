//
//  ConcurrentActionExecutorTests.swift
//  ConcurrentActionExecutorTests
//
//  Created by Marko Engelman on 12/01/2022.
//

import XCTest
@testable import ConcurrentActionExecutor

class ConcurrentActionExecutorTests: XCTestCase {
  func test_init_storesCorrectQueue() {
    let queue = DispatchQueue.main
    let sut = makeSUT(queue: queue)
    XCTAssertEqual(sut.queue, queue)
  }
}

// MARK: - Private
private extension ConcurrentActionExecutorTests {
  func makeSUT(queue: DispatchQueue = .main) -> ConcurrentActionExecutor {
    let sut = ConcurrentActionExecutor(outputQueue: queue)
    return sut
  }
}
