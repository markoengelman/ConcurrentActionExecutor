//
//  ConcurrentActionExecutor.swift
//  ConcurrentActionExecutor
//
//  Created by Marko Engelman on 12/01/2022.
//

import Foundation

final class ConcurrentActionExecutor {
  typealias Action = () -> Void
  let queue: DispatchQueue
  let action: Action
  
  init(outputQueue: DispatchQueue, action: @escaping Action) {
    self.queue = outputQueue
    self.action = action
  }
  
  func execute(completion: @escaping () -> Void) {
    queue.async { [action] in
      action()
      completion()
    }
  }
}
