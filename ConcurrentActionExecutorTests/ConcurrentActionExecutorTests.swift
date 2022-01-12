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
  
  func test_execute_completesOnTargetQueue() {
    let startingQueue = DispatchQueue.global(qos: .background)
    let targetQueue = DispatchQueue.main
    let sut = makeSUT(queue: targetQueue)
    
    let exp = expectation(description: "Waiting for execution to complete on \(targetQueue)")
    
    startingQueue.async {
      sut.execute {
        if Thread.isMainThread {
          exp.fulfill()
        } else {
          XCTFail("Failed to complete on \(targetQueue)")
        }
      }
    }
    wait(for: [exp], timeout: 0.1)
  }
}

// MARK: - Private
private extension ConcurrentActionExecutorTests {
  func makeSUT(queue: DispatchQueue = .main) -> ConcurrentActionExecutor {
    let sut = ConcurrentActionExecutor(outputQueue: queue)
    return sut
  }
}
