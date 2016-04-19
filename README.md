# iOS-MultiThread-NSOperation
iOS MultiThread NSOperation &amp; NSOperationQueue

This is a summary of learning NSOperation and NSOperationQueue. The goal is to help other beginners and myself to understand how the NSOperation works and how to use it. 

# Example of Asynchronous NSOperation Queue
I rewrote the example in [NSOperation and NSOperationQueue Tutorial in Swift](http://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift) using Objective-C, and add operation dependencies between image download operations in download queue and image filtration operations in filtration queue. Thus, we do not need to control the workflow of executing download operations and filtration operations. Once the state is New, the download operation will start, and the filtration operation will start right after the download operation finished.

# What are synchronous queue and asynchronous queue?
### Synchronous queue: 
When you execute something synchronously, you wait for it to finish before moving on to another task. 

### Asynchronous queue:
When you execute something asynchronously, you can move on to another task before it finishes.

# Difference between NSOperation and GCD
GCD is better for performing short-running tasks asynchronously. It has minimum performance and uses less memory. It cannot be cancelled directly or easily.

NSOperation is more suitable for long-running tasks that may need to be cancelled or have complex dependences between tasks, and we have more control on executing operations. The NSOperation class is key-value coding (KVC) and key-value observing (KVO) compliant for several of its properties. Also, we are able to create subclasses for NSOperation, and we do not use NSOperation class directly. We use its subclasses, NSInvocationOperation and NSBlockOperation. Typically, we execute operations by adding them onto an operation queue. And NSOperation is a high level wrapper of GCD. Actually, NSOperation can be used for controlling workflows by building dependencies.


# Working with NSOperation
### Something better to know:
The NSOperation class is an abstract class you use to encapsulate the code and data associated with a single task. Because it is abstract, you do not use this class directly but instead subclass or use one of the system-defined subclasses (NSInvocationOperation or NSBlockOperation) to perform the actual task.
An operation object is a single-shot object—that is, it executes its task once and cannot be used to execute it again. You typically execute operations by adding them to an operation queue (an instance of the NSOperationQueue class). An operation queue executes its operations either directly, by running them on secondary threads, or indirectly using the libdispatch library (also known as Grand Central Dispatch).
If you do not want to use an operation queue, you can execute an operation yourself by calling its start method directly from your code. Executing operations manually does put more of a burden on your code, because starting an operation that is not in the ready state triggers an exception. The ready property reports on the operation’s readiness.
The NSOperation class is key-value coding (KVC) and key-value observing (KVO) compliant for several of its properties.
We typically execute operations by adding them to an NSOperationQueue. By using the default value of maxConcurrentQueueCount, the operation queue will execute operations asynchronously. 

### States without cancellation:
Pending ->  Ready -> Execute -> Finished

### Cancellation:
By subclassing NSOperation, we can add task to be executed after cancellation, for instance, stop networking connection. 
When finished, the system will take time to move the operation from background thread to the main thread and set its state to be finished. We cannot cancel an operation during this time.

### Dependency:
let operationA = …

let operationB = …

operationB.addDependency(operationA)

operationB will become dependent on the successful execution of operationA. This means, operationB will not be executed util after operationA. Be careful about deadlock.
