    import XCTest
    @testable import BaseServiceManager

    final class BaseServiceManagerTests: XCTestCase {
        func testUrlSessionReturnSuccess() {
            // setup expectation
            let expect = self.expectation(description: "Download mock image from pexels")
            // use pexels mock image service as testing API service
            let url = URL(string: ExampleApiEndpoints.urlWithEndpoint(.SEARCH))
            let fields = ExampleApiEndpoints.headerFields
            let arguments:[String: AnyObject] = ["query": "dog" as AnyObject, "per_page":10 as AnyObject]
            
            // compose request
            let request = BaseApiRequest.composeRequest(type: ApiRequestType.GET, url: url!, headerFields: fields ,arguments: arguments)
            BaseServiceManager.shared.performRequest(urlRequest: request, success: {dictionary in
                XCTAssertNotNil(dictionary, "No data was downloaded")
                print(dictionary as Any? ?? "")
                expect.fulfill()
            }) { (error) in
                print("error")
            }
            wait(for: [expect], timeout: 10.0)
        }
    }
