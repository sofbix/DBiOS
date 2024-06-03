
# DBiOS

## What is it?

Hub of examples and tests DataBase frameworks wich used by iOS developers.
It needs for compare code, features and performance of different frameworks.

## What frameworks to compare:

![SwiftData](Docs/SwiftData.png) [SwiftData](https://developer.apple.com/documentation/SwiftData)
![Realm](Docs/Realm.png) [Realm](https://github.com/realm/realm-swift)
![Fluent](Docs/Fluent.png) [Fluent](https://github.getafreenode.com/vapor/fluent-sqlite-driver)
![CoreStore](Docs/CoreStore.png) [CoreStore](https://github.com/JohnEstropia/CoreStore)

## Than to test

I have implemented a DBiOS app for performance tets that compiles from target `PerformanceAllDb`:

<img src="Docs/Screen1.png" alt="Screen" style="height:639px;"/>

### Async (concurrent requests)

Usually, mobile applications execute queries serially, from one or more Threads. 
But test can emulate concurrent execution with high load to Processor.
The app uses Swift Concurrency technology to test multithreaded operation.
What is difference:

#### Serial

```swift
    for i in 1...iterationCount{
        try await handle(i)
    }
```

#### Concurrent

```swift
    try await withThrowingTaskGroup(of: Void.self) { group in
        for i in 1...iterationCount{
            group.addTask {
                try await handle(i)
            }
        }
        try await group.waitForAll()
    }
```

## License

MIT license. See [LICENSE](LICENSE) for details.
