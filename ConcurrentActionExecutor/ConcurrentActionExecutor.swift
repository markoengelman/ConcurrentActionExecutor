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
  
  init(outputQueue: DispatchQueue, action: @escaping Action) {
    self.queue = outputQueue
    self.action = action
  }
  
  func execute(_ input: Input, completion: @escaping (Output) -> Void) {
    Task(priority: .high) {
      let output = action(input)
      queue.async { completion(output) }
    }
  }
}
