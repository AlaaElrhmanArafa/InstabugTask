//
//  InstabugNetworkClientTests.swift
//  InstabugNetworkClientTests
//
//  Created by Yousef Hamza on 1/13/21.
//

import XCTest
@testable import InstabugNetworkClient

class NetworkClientMoc: XCTestCase {

    let data = Data(count:  200)
    let moreThan1MData = Data(count: 1024*1024*2)
    
    public func get(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        completionHandler(moreThan1MData)
    }

    public func post(_ url: URL, payload: Data?=nil, completionHandler: @escaping (Data?) -> Void) {
        completionHandler(data)
    }

    public func put(_ url: URL, payload: Data?=nil, completionHandler: @escaping (Data?) -> Void) {
        completionHandler(data)
    }

    public func delete(_ url: URL, completionHandler: @escaping (Data?) -> Void) {
        
        completionHandler(data)
    }
    
    func test_execution(){
        guard let url = URL(string: "https://httpbin.org/bytes/128") else { return }
        NetworkClient.shared.get(url) { data in
            XCTAssertNotNil(data)
        }
    }

}
