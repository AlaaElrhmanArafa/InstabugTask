#  Instabug Task
This Framework to record all requests and responses and simple app as a POC




## Documentation
### The module has a LoggerHandler singleton class as an entry point to logging framework
    the limition for saving exists in Handler 
    
The logger accessible functions other targets
    - clearLogs
    - allNetworkRequests
    - count
 
LoggerHandler interact with DB Manager using one interface
``` swift
    protocol RecieveRequestProtocol{
        func saveRequest(url:String,
                         statusCode:Int,
                         requestPayload:Data?,
                         responsePayload:Data?,
                         error:Error?)
        
        func getAllRequests() -> [LoggerModel]
        func delete(at index:Int)
        func clearLogs()
        var  count: Int { get }
    }
```

### CoreDataManager is the DB Manager of the app, 
    it has the core data main functionalities
    confirming to RecieveRequestProtocol, Saving logic is sperated than reading and parsing logic
    CoreDataManager is not accessible from other targets

## Testing
    1- Create unit testing for limitations, saving process and items count
    2- create mocking network client returns data in all funcs but get returns data bigger than limitation for testing
    3- Make the tests not sharing status 
    4- the task has a simple UI for manaual testing if needed
