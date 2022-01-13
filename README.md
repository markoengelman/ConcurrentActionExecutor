# ConcurrentActionExecutor
- Simple wrapper around Task API which allows us to use execute long-running (or any other) tasks in the backound thread
- To read more about motivation behind it please see my article about it: https://markoengelman.com/async-execution-of-long-running-tasks-with-task-api/

## Code
```Swift
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
  
  func execute(_ input: Input) async -> Output {
    await runTask(input)
  }
  
  func execute() async -> Output where Input == Void {
    await runTask(())
  }
  
  @MainActor
  func executeAndDeliverOnMain(_ input: Input) async -> Output {
    await runTask(input)
  }
  
  @MainActor
  func executeAndDeliverOnMain() async -> Output where Input == Void {
    await runTask(())
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
  
  func runTask(_ input: Input) async -> Output {
    await Task(priority: priority, operation: { action(input) }).value
  }
}
```
## How to use
- For demostrantion how to use check provided Unit Tests with usage demonstration.
