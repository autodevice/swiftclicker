import Foundation

public struct JSONRPCRequest: Encodable {
    let jsonrpc: String = "2.0"
    let id: Int
    let method: String
    let params: [Any]
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc, id, method, params
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(id, forKey: .id)
        try container.encode(method, forKey: .method)
        
        var paramsContainer = container.nestedUnkeyedContainer(forKey: .params)
        for param in params {
            if let stringParam = param as? String {
                try paramsContainer.encode(stringParam)
            } else if let intParam = param as? Int {
                try paramsContainer.encode(intParam)
            } else if let doubleParam = param as? Double {
                try paramsContainer.encode(doubleParam)
            }
        }
    }
}

public struct JSONRPCResponse: Codable {
    let jsonrpc: String
    let id: Int
    let result: AnyCodable?
    let error: JSONRPCError?
}

public struct JSONRPCError: Codable {
    let code: Int
    let message: String
    let data: String?
}

public struct AnyCodable: Codable {
    let value: Any
    
    public init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else {
            value = ()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let bool = value as? Bool {
            try container.encode(bool)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        } else {
            try container.encodeNil()
        }
    }
}

public enum HTTPClientError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case jsonrpcError(String)
    case httpError(Int, String)
}

public class HTTPClient {
    private let baseURL: String
    private let session: URLSession
    private var requestID: Int = 1
    
    public init(host: String, port: Int) {
        self.baseURL = "http://\(host):\(port)"
        self.session = URLSession.shared
    }
    
    public func jsonrpcCall(method: String, params: [Any] = []) async throws -> Any? {
        guard let url = URL(string: "\(baseURL)/jsonrpc/0") else {
            throw HTTPClientError.invalidURL
        }
        
        let request = JSONRPCRequest(id: requestID, method: method, params: params)
        requestID += 1
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("uiautomator2", forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("", forHTTPHeaderField: "Accept-Encoding")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPClientError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw HTTPClientError.httpError(httpResponse.statusCode, errorMessage)
            }
            
            let jsonResponse = try JSONDecoder().decode(JSONRPCResponse.self, from: data)
            
            if let error = jsonResponse.error {
                throw HTTPClientError.jsonrpcError("\(error.code): \(error.message)")
            }
            
            return jsonResponse.result?.value
            
        } catch let error as HTTPClientError {
            throw error
        } catch {
            throw HTTPClientError.networkError(error)
        }
    }
    
    public func ping() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/ping") else {
            throw HTTPClientError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("uiautomator2", forHTTPHeaderField: "User-Agent")
        urlRequest.timeoutInterval = 5.0
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPClientError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                return false
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            return responseString.trimmingCharacters(in: .whitespacesAndNewlines) == "pong"
            
        } catch {
            return false
        }
    }
}