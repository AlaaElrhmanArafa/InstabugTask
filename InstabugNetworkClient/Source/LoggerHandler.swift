//
//  LoggerClient.swift
//  InstabugNetworkClient
//
//  Created by AlaaElrhman on 21/10/2022.
//

import Foundation
import CoreData

fileprivate let maxRequestsLimits = 1000

/// The abstract layer between  DBManager, LoggerHandler. 
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

/// This class responsibility is  parsing and preparing data to be saved in DBManager, 
public class LoggerHandler{
    
    public static let shared = LoggerHandler()
    var delegate: RecieveRequestProtocol?
    
    init(delegate: RecieveRequestProtocol? = CoreDataManager.shared) {
        self.delegate = delegate
    }
    
    /// Parsing the request and response, call the DB Manager(CoreData manager) using Delegate to store parsed data
    /// - Parameters:
    ///   - url: url of request
    ///   - statusCode: response status code
    ///   - requestPayload: request payload data (Optional)
    ///   - responsePayload: response payload data (Optional)
    ///   - error: error if happened (Optional)
    func saveRequestAndResponse(url:String,
                                statusCode:Int,
                                requestPayload:Data?,
                                responsePayload:Data?,
                                error:Error?){
        
        let requestData = getPayloadData(payload: requestPayload)
        let responseData = getPayloadData(payload: responsePayload)
        
        self.checkCounts()

        delegate?.saveRequest(url: url,
                              statusCode: statusCode,
                              requestPayload: requestData,
                              responsePayload: responseData,
                              error: error)
    }
    
    /// clear all stored Requests
    public func clearLogs() {
        delegate?.clearLogs()
    }
    
    /// Get all stored Requests
    /// - Returns: Array of stored Requests
     public func allNetworkRequests() -> [LoggerModel]{
         return delegate?.getAllRequests() ?? []
    }
    
    public var count:Int{
        return delegate?.count ?? 0
    }
}
//MARK: - limitation logic
extension LoggerHandler{
    /// This function aims to calculate the max size of payload in both request and response,
    /// if the payload is bigger than 1MB it should return "payload too large"
    /// - Parameter payload: data
    /// - Returns: payload or "payload too large" as Data
    func getPayloadData(payload:Data?) -> Data?{
        let payloadSize = payload?.dataSizeInMB() ?? 0
        return payloadSize > 1 ? "payload too large".data(using: .utf8) : payload
    }
    
    /// This function check if CoreData rows excced the limit, if yes it delete the first item
    /// - Parameter maximumValue: the limit when the app should delete the first items before adding new one instaed
    func checkCounts(with maximumValue:Int = maxRequestsLimits){
        if delegate?.count == maximumValue{
            delegate?.delete(at: 0)
        }
    }
}
