//
//  LoggerHandlerTests.swift
//  InstabugNetworkClientTests
//
//  Created by AlaaElrhman on 22/10/2022.
//

import XCTest
@testable import InstabugNetworkClient

final class LoggerHandlerTests: XCTestCase {
    
    var moc_LoggerHandler:LoggerHandler!
    var moc_delegate: RecieveRequestProtocol?
    let url = URL(string: "https://httpbin.org/anything")!



    override func setUpWithError() throws {
        try super.setUpWithError()
        moc_LoggerHandler = LoggerHandler()
        moc_delegate = CoreDataManager.shared
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        moc_LoggerHandler.clearLogs()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    /// Test  the Saved number of rows
    func test_SaveRightNumbers() throws{
        NetworkClientMoc().post(url) { data in
            self.saveToDB(url: self.url, data: data)
            XCTAssertEqual(self.moc_delegate?.count, 1)
            
            self.saveToDB(url: self.url, data: data)
            XCTAssertEqual(self.moc_delegate?.count, 2)
        }
    }
    
    /// Test Saved Content
    func test_SaveRequestAndResponse() throws{
        guard let url = URL(string: "https://httpbin.org/anything") else { return }
        
        NetworkClientMoc().post(url, payload: "testRequstPayload".data(using: .utf8)) { data in
            self.saveToDB(url: url, data: data, payload: "testRequstPayload".data(using: .utf8))
            if let firstLog = self.moc_delegate?.getAllRequests().first{
                XCTAssertNotNil(firstLog.urlString)
                XCTAssertEqual(firstLog.urlString, url.absoluteString)
                XCTAssertEqual(firstLog.responseData?.responsePayload, data)
                XCTAssertEqual(firstLog.requestPayload, "testRequstPayload".data(using: .utf8))
            }else{
                XCTAssertEqual(self.moc_delegate?.count, 1)
            }
        }
    }
    
    
    /// Test if  func return Big Payload repalced with "payload too large"
    func test_biggerThan1M() throws{
        NetworkClientMoc().get(url) { data in // get func in NetworkMoc returns data bigger than 1 MB
            XCTAssertNotNil(self.moc_LoggerHandler.getPayloadData(payload: data))
            XCTAssertEqual(self.moc_LoggerHandler.getPayloadData(payload: data), "payload too large".data(using: .utf8))
        }
    }
    
    /// Test if delete operation works, in this Test I changed the Limit to be 10 for easeier test
    func test_saveMoreThan10() throws{
        NetworkClientMoc().get(url) { data in
            for _ in 0...12{
                self.moc_LoggerHandler.checkCounts(with: 10)
                self.saveToDB(url: self.url, data: data)
            }
            XCTAssertEqual(self.moc_LoggerHandler.delegate?.count, 10)
        }
    }
    
    /// Helper Function to simulate storage to CoreData
    func saveToDB(url:URL, data: Data?, payload:Data? = nil){
        self.moc_LoggerHandler.saveRequestAndResponse(url: url.absoluteString,
                                                      statusCode: 200,
                                                      requestPayload: payload,
                                                      responsePayload: data,
                                                      error: nil)
    }
}
