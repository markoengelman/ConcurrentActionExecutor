//
//  ConcurrentActionExecutor.swift
//  ConcurrentActionExecutor
//
//  Created by Marko Engelman on 12/01/2022.
//

import Foundation

final class ConcurrentActionExecutor {
  let queue: DispatchQueue
  
  init(outputQueue: DispatchQueue) {
    self.queue = outputQueue
  }
  
  func execute(completion: @escaping () -> Void) {
    queue.async { completion() }
  }
}
