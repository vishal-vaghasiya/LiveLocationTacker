//
//  ApiManager.swift
//
//  Created by Apple on 20/12/23.
//

import Foundation
import Reachability

let reachability = try! Reachability()
var interNetConnectionAvailable:Bool?


enum APIError: Error {
    case invalidURL
    case requestFailed
    case invalidData
    case unableToCreateImageURL
    case unableToConvertDataIntoImage
    case unableToCreateURLForURLRequest
    case invalidParameter
    case fileNotFound
    case unableToCreateRequest
    case networkError(Error)
    case invalidResponse
    case dataSerializationError
    case noInternetConnection
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

class ApiManager {
    
    static let shared = ApiManager()

    func fetch<T: Decodable>(url: URL,method: HTTPMethod = .get,headers: [String: Any]? = nil,body: Data? = nil,completion: @escaping (Result<T, Error>) -> Void) {
        guard reachability.connection != .unavailable else {
            completion(.failure(APIError.noInternetConnection))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Set headers if provided
        headers?.forEach { key, value in
            request.setValue(value as? String, forHTTPHeaderField: key)
        }
        
        // Set request body if provided
        if let body = body {
            request.httpBody = body
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 50000
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(.failure(APIError.requestFailed))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                completion(.failure(APIError.requestFailed))
                return
            }

            guard let data = data, let base64String = String(data: data, encoding: .utf8) else {
                completion(.failure(APIError.invalidData))
                return
            }
            
            print(base64String)
            
            // Decode Base64 string
            if let decodedData = Data(base64Encoded: base64String) {
                do {
                    let decodedJson = try JSONDecoder().decode(T.self, from: decodedData)
                    completion(.success(decodedJson))
                } catch {
                    completion(.failure(error))
                }
            } 
            else {
                completion(.failure(APIError.requestFailed))
            }
            
//            do {
//                let decodedData = try JSONDecoder().decode(T.self, from: data)
//                completion(.success(decodedData))
//            }
//            catch {
//                completion(.failure(error))
//            }
        }
        task.resume()
    }
}

