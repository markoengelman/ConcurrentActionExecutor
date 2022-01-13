//
//  ConcurrentActionExecutorTests.swift
//  ConcurrentActionExecutorTests
//
//  Created by Marko Engelman on 12/01/2022.
//

import XCTest
@testable import ConcurrentActionExecutor

class ConcurrentActionExecutorTests: XCTestCase {
  func test_execute_completesOnMainQueue() {
    let sut = makeSUT()
    let exp = expectation(description: "Waiting for execution to complete on Main Queue")
    sut.executeAndDeliverOnMain {
      if Self.isOnMainQueue {
        exp.fulfill()
      } else {
        XCTFail("Failed to complete on Main Queue")
      }
    }
  
    wait(for: [exp], timeout: 0.1)
  }
  
  func test_execute_invokes_action_off_mainQueue() {
    let exp = expectation(description: "Waiting for action to be executed off main queue")
    let sut = makeSUT(action: action(for: exp))
    sut.execute(Void()) { }
    wait(for: [exp], timeout: 0.1)
  }
  
  func test_execute_hasNoSideEffects_onInjectedActionResult() {
    let expectedResult = Self.anyResult
    let anyAction = AnyActionMock(result: expectedResult)
    let sut = AnyConcurrentActionExecutor(action: anyAction.run)
    let exp = expectation(description: "Waiting for reusult")
    
    var receivedResult: AnyActionResult?
    sut.execute(Self.anyRequest) { result in
      receivedResult = result
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 0.1)
    XCTAssertEqual(receivedResult, expectedResult)
  }
  
  func test_allExecutes_deliversResult() {
    let exp = expectation(description: "Waiting for all expectations to complete")
    exp.expectedFulfillmentCount = 4
    
    ConcurrentActionExecutor<Void, Void>(action: { }).execute { exp.fulfill() }
    ConcurrentActionExecutor<Void, AnyActionResult>(action: { Self.anyResult }).execute { _ in exp.fulfill() }
    ConcurrentActionExecutor<AnyActionRequest, Void>(action: { _ in }).execute(Self.anyRequest, completion: { exp.fulfill() })
    ConcurrentActionExecutor<AnyActionRequest, AnyActionResult>(action: { _ in Self.anyResult }).execute(Self.anyRequest, completion: { _ in exp.fulfill() })
    
    wait(for: [exp], timeout: 0.1)
  }
}

// MARK: - Private
private extension ConcurrentActionExecutorTests {
  func makeSUT(priority: TaskPriority = .high, action: @escaping () -> Void = { }) -> ConcurrentActionExecutor<Void, Void> {
    let sut = ConcurrentActionExecutor<Void, Void>(priority: priority, action: action)
    return sut
  }
  
  static var isOnMainQueue: Bool {
    return Thread.isMainThread
  }
  
  func action(for expectation: XCTestExpectation) -> () -> Void {
    return {
      if !Self.isOnMainQueue {
        expectation.fulfill()
      } else {
        XCTFail("Failed to execute action off main queue")
      }
    }
  }
  
  static let anyResult = 10
  static let anyRequest = 1
}

private typealias AnyActionRequest = Int
private typealias AnyActionResult = Int
private typealias AnyConcurrentActionExecutor = ConcurrentActionExecutor<AnyActionRequest, AnyActionResult>

private protocol AnyAction {
  func run(request: AnyActionRequest) -> AnyActionResult
}

private class AnyActionMock: AnyAction {
  let result: AnyActionResult
  
  init(result: AnyActionResult) {
    self.result = result
  }
  
  func run(request: AnyActionRequest) -> AnyActionResult {
    return result
  }
}
