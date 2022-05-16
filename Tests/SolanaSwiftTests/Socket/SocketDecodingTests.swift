import XCTest
import SolanaSwift

class SocketDecodingTests: XCTestCase {
    
    func testDecodingSocketSubscription() throws {
        let string = #"{"jsonrpc":"2.0","result":22529999,"id":"ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E"}"#
        let result = try JSONDecoder().decode(SocketSubscriptionResponse.self, from: string.data(using: .utf8)!)
        
        XCTAssertEqual(result.id, "ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E")
        XCTAssertEqual(result.result, 22529999)
    }
    
    func testDecodingSocketUnsubscription() throws {
        let string = #"{ "jsonrpc": "2.0", "result": true, "id": "ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E" }"#
        let result = try JSONDecoder().decode(SocketUnsubscriptionResponse.self, from: string.data(using: .utf8)!)
        
        XCTAssertEqual(result.id, "ADFB8971-4473-4B16-A8BC-63EFD2F1FC8E")
        XCTAssertEqual(result.result, true)
    }
    
    func testDecodingSOLAccountNotification() throws {
        let string = #"{"jsonrpc":"2.0","method":"accountNotification","params":{"result":{"context":{"slot":80221533},"value":{"data":["","base64"],"executable":false,"lamports":41083620,"owner":"11111111111111111111111111111111","rentEpoch":185}},"subscription":46133}}"#
        let result = try JSONDecoder().decode(SocketNativeAccountNotification.self, from: string.data(using: .utf8)!)
        
        XCTAssertEqual(result.method, "accountNotification")
        XCTAssertEqual(result.lamports, 41083620)
    }
    
    func testDecodingProgramNotification() throws {
        let string = #"{"jsonrpc":"2.0","method":"programNotification","params":{"result":{"context":{"slot":5208469},"value":{"pubkey":"H4vnBqifaSACnKa7acsxstsY1iV1bvJNxsCY7enrd1hq","account":{"data":["11116bv5nS2h3y12kD1yUKeMZvGcKLSjQgX6BeV7u1FrjeJcKfsHPXHRDEHrBesJhZyqnnq9qJeUuF7WHxiuLuL5twc38w2TXNLxnDbjmuR","base58"],"executable":false,"lamports":33594,"owner":"11111111111111111111111111111111","rentEpoch":636}}},"subscription":24040}}"#
        let result = try JSONDecoder().decode(SocketProgramAccountNotification.self, from: string.data(using: .utf8)!)
        
        XCTAssertEqual(result.method, "programNotification")
        XCTAssertEqual(result.subscription, 24040)
    }
    
    func testDecodingTokenAccountNotification() throws {
        let string = #"{"jsonrpc":"2.0","method":"accountNotification","params":{"result":{"context":{"slot":80216037},"value":{"data":{"parsed":{"info":{"isNative":false,"mint":"kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6","owner":"6QuXb6mB6WmRASP2y8AavXh6aabBXEH5ZzrSH5xRrgSm","state":"initialized","tokenAmount":{"amount":"390000101","decimals":5,"uiAmount":3900.00101,"uiAmountString":"3900.00101"}},"type":"account"},"program":"spl-token","space":165},"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":185}},"subscription":42765}}"#
        
        let result = try JSONDecoder().decode(SocketTokenAccountNotification.self, from: string.data(using: .utf8)!)
        
        XCTAssertEqual(result.method, "accountNotification")
        XCTAssertEqual(result.tokenAmount?.amount, "390000101")
    }
    
    func testDecodingSignatureNotification() throws {
        let string = #"{"jsonrpc":"2.0","method":"signatureNotification","params":{"result":{"context":{"slot":80768508},"value":{"err":null}},"subscription":43601}}"#
        
        let result = try JSONDecoder().decode(SocketSignatureNotification.self, from: string.data(using: .utf8)!)
        
        XCTAssertEqual(result.method, "signatureNotification")
        XCTAssertEqual(result.isConfirmed, true)
    }

    func testDecodingLogsNotification() throws {
        let string = #"{"jsonrpc":"2.0","method":"logsNotification","params":{"result":{"context":{"slot":5208469},"value":{"signature":"5h6xBEauJ3PK6SWCZ1PGjBvj8vDdWG3KpwATGy1ARAXFSDwt8GFXM7W5Ncn16wmqokgpiKRLuS83KUxyZyv2sUYv","err":null,"logs":["BPF program 83astBRguLMdt2h5U1Tpdq5tjFoJ6noeGwaY3mDLVcri success"]}},"subscription":24040}}"#
        
        let result = try JSONDecoder().decode(SocketLogsNotification.self, from: string.data(using: .utf8)!)
        
        XCTAssertEqual(result.method, "logsNotification")
        XCTAssertEqual(result.logs?.first, "BPF program 83astBRguLMdt2h5U1Tpdq5tjFoJ6noeGwaY3mDLVcri success")
        
    }
}
