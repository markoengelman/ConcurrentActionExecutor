//
//  ConcurrentActionExecutor.swift
//  ConcurrentActionExecutor
//
//  Created by Marko Engelman on 12/01/2022.
//

import Foundation

final class ConcurrentActionExecutor<Input, Output> {
  typealias Action = (Input) -> Output
  typealias ActionOutputCompletion = (Output) -> Void
  
  let action: Action
  let priority: TaskPriority
  
  init(priority: TaskPriority = .high, action: @escaping Action) {
    self.action = action
    self.priority = priority
  }
  
  func execute(_ input: Input, completion: @escaping ActionOutputCompletion) {
    runTask(input, completion)
  }
  
  func execute(completion: @escaping ActionOutputCompletion) where Input == Void {
    runTask((), completion)
  }
  
  func executeAndDeliverOnMain(_ input: Input, completion: @MainActor @escaping (Output) -> Void) {
    runTaskAndDeliverOnMain(input, completion)
  }
  
  func executeAndDeliverOnMain(completion: @MainActor @escaping (Output) -> Void) where Input == Void {
    runTaskAndDeliverOnMain((), completion)
  }
}

// MARK: - Private
private extension ConcurrentActionExecutor {
  func runTask(_ input: Input, _ completion: @escaping (Output) -> Void) {
    Task(priority: priority) {
      let output = action(input)
      completion(output)
    }
  }
  
  func runTaskAndDeliverOnMain(_ input: Input, _ completion: @MainActor @escaping (Output) -> Void) {
    Task(priority: priority) {
      let output = action(input)
      await completion(output)
    }
  }
}
