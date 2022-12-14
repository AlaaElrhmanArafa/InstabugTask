//
//  NetworkClient.swift
//  InstabugNetworkClient
//
//  Created by Yousef Hamza on 1/13/21.
//

import Foundation
import CoreData

public class NetworkClient {
    public static var shared = NetworkClient()

    // MARK: Network requests
    public func get(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "GET", payload: nil, completionHandler: completionHandler)
    }

    public func post(_ url: URL, payload: Data?=nil, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "POST", payload: payload, completionHandler: completionHandler)
    }

    public func put(_ url: URL, payload: Data?=nil, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "PUT", payload: payload, completionHandler: completionHandler)
    }

    public func delete(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        executeRequest(url, method: "DELETE", payload: nil, completionHandler: completionHandler)
    }

    func executeRequest(_ url: URL, method: String, payload: Data?, completionHandler: @escaping (Data?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = payload
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in

            guard let httpURLResponse = response as? HTTPURLResponse else {
                completionHandler(nil)
                return
            }
            
            LoggerHandler.shared.saveRequestAndResponse(url: url.absoluteString,
                                                       statusCode: httpURLResponse.statusCode,
                                                       requestPayload: payload,
                                                       responsePayload: data,
                                                       error: error)
            
            DispatchQueue.main.async {
                completionHandler(data)
            }
            return
        }.resume()
    }

    // MARK: Network recording
    public func allNetworkRequests() -> [LoggerModel] {
        return LoggerHandler.shared.allNetworkRequests()
    }
}
