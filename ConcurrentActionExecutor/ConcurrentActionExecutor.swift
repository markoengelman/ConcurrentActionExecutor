//
//  ConcurrentActionExecutor.swift
//  ConcurrentActionExecutor
//
//  Created by Marko Engelman on 12/01/2022.
//

import Foundation

final class ConcurrentActionExecutor<Input, Output> {
  typealias Action = (Input) -> Output
  
  let queue: DispatchQueue
  let action: Action
  let priority: TaskPriority
  
  init(outputQueue: DispatchQueue, priority: TaskPriority = .high, action: @escaping Action) {
    self.queue = outputQueue
    self.action = action
    self.priority = priority
  }
  
  func execute(_ input: Input, completion: @escaping (Output) -> Void) {
    runTask(input, completion)
  }
  
  func execute(completion: @escaping (Output) -> Void) where Input == Void {
    runTask((), completion)
  }
  
  func execute(completion: @escaping () -> Void) where Input == Void, Output == Void {
    runTask((), completion)
  }
  
  func execute(_ input: Input, completion: @escaping () -> Void) where Output == Void {
    runTask(input, completion)
  }
  
  private func runTask(_ input: Input, _ completion: @escaping (Output) -> Void) {
    Task(priority: priority) {
      let output = action(input)
      queue.async {
        completion(output)
      }
    }
  }
}
