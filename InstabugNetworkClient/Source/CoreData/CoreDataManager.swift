//
//  CoreDataManager.swift
//  InstabugNetworkClient
//
//  Created by AlaaElrhman on 21/10/2022.
//

import Foundation
import CoreData

 class CoreDataManager{
    
    //MARK: - singleton
    static let shared = CoreDataManager()
    
    // MARK: - Entites
    private let logEntity = "LoggerModel"

    
    // MARK: - CoreData Stack
    private var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: CoreDataManager.self)
        let model = NSManagedObjectModel.mergedModel(from: [bundle])!
        let container = NSPersistentContainer(name: "InstabugNetworkClient",managedObjectModel: model)
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    lazy var mainManagedContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
}
// MARK: - Save
extension CoreDataManager{
    private func save(){
        if mainManagedContext.hasChanges{
            do{
                try self.persistentContainer.viewContext.save()
            }catch let error{
                fatalError("error in save at coreData: \(error.localizedDescription)")
            }
        }
    }
}
// MARK: - Deletion
extension CoreDataManager{
    /// delete all BD Rows
    public func clearLogs() {
        persistentContainer.performBackgroundTask { backgroundManagedContext in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.logEntity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            backgroundManagedContext.performAndWait {
                do{
                    _ = try backgroundManagedContext.execute(deleteRequest)
                    _ = try backgroundManagedContext.save()
                }catch{
                    fatalError("error in clearLogs at coreData:\(error.localizedDescription)")
                }
            }
        }
    }
    
    /// delete at specific index from given array
    /// - Parameters:
    ///   - index: Int, The index will be removed
    ///   - allLogs: All Rows
    private func deleteLog(at index: Int, allLogs: [LoggerModel]) {
        let objectID = allLogs[index].objectID
        persistentContainer.performBackgroundTask{ backgroundManagedContext in
            backgroundManagedContext.performAndWait {
                if let managedObject = try? backgroundManagedContext.existingObject(with: objectID) {
                    do{
                        backgroundManagedContext.delete(managedObject)
                        try backgroundManagedContext.save()
                    }catch{
                        fatalError("error in deleteLog at coreData:\(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
// MARK: - fetch
extension CoreDataManager{
    /// Get all Rows in DB
    /// - Returns: Array of CoreData Model
    private func fetchLogs() -> [LoggerModel] {
        var logsArr: [LoggerModel] = []
        let fetchRequest = NSFetchRequest<LoggerModel>(entityName: logEntity)

        mainManagedContext.performAndWait {
            do {
                logsArr = try mainManagedContext.fetch(fetchRequest)
            } catch {
                fatalError("error in fetchLogs \(error)")
            }
        }
        return logsArr
    }
}
extension CoreDataManager: RecieveRequestProtocol{
    
    func getAllRequests() -> [LoggerModel]{
        return fetchLogs()
    }
    
    /// Save requests to CoreData
    /// - Parameters:
    ///   - url: string, url of request
    ///   - statusCode: Int, 
    ///   - requestPayload: Data, Request Payload (Optional)
    ///   - responsePayload: Data, Response payload (Optional)
    ///   - error: Error, error if happened (Optional)
    func saveRequest(url: String, statusCode: Int, requestPayload: Data?, responsePayload: Data?, error: Error?) {
                
        persistentContainer.performBackgroundTask { backgroundManagedContext in
            let log = LoggerModel(context: backgroundManagedContext)
            
            log.urlString = url
            log.statusCode = Int64(statusCode)
            log.requestPayload = requestPayload
            
            if let error = error as? NSError{
                log.errorData = self.getErrorModel(error: error, context: backgroundManagedContext)
            }
            
            if let responsePayload = responsePayload{
                log.responseData = self.getResponseModel(response: responsePayload, context: backgroundManagedContext)
            }
            
            backgroundManagedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            backgroundManagedContext.insert(log)
            do{
                try backgroundManagedContext.save()
            }catch let error{
                fatalError("error in save at coreData: \(error.localizedDescription)")
            }
        }

    }
    
    /// count of items in DB
    var count: Int{
        return fetchLogs().count
    }
    
    /// Delete at Index from CoreData
    /// - Parameter index: The index of deleted row
    func delete(at index: Int) {
        persistentContainer.performBackgroundTask{ backgroundManagedContext in
            let fetchRequest = NSFetchRequest<LoggerModel>(entityName: self.logEntity)
            do{
                let allLogs = try backgroundManagedContext.fetch(fetchRequest)
                self.deleteLog(at: index, allLogs: allLogs)
            }catch let error{
                fatalError("Error in deleting item at Index:\(index) from coreData \(error)")
            }
        }
    }
}
extension CoreDataManager{
    /// create Error Model if exist
    /// - Parameter error: error as Error
    /// - Returns: Error Model in CoreData
    func getErrorModel(error:Error, context:NSManagedObjectContext) -> ErrorModel{
        let error = error as NSError
        let errorModel = ErrorModel(context: context)
        errorModel.domainError = error.domain
        errorModel.errorCode = Int64(error.code)
        
        return errorModel
    }
    
    /// create ResponseModel in CoreData
    /// - Parameter response: responseData
    /// - Returns: ResponseModel
    func getResponseModel(response:Data, context:NSManagedObjectContext) -> ResponseModel{
        let responseModel = ResponseModel(context: context)
        responseModel.responsePayload = response
        
        return responseModel
    }
}
