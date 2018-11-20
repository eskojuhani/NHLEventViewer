//
//  NetworkClient.swift
//
// thanks to internet
//

import Foundation


protocol Endpoint {
    var base: String { get }
    var path: String { get }
}

extension Endpoint {
    func urlComponents(_ parameters: [String: String]) -> URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        components.queryItems = parameters.map {URLQueryItem(name: $0, value: $1)}
        
        return components
    }
    
    func request(parameters: [String: String]) -> URLRequest {
        let url = urlComponents(parameters).url!
        return URLRequest(url: url)
    }
    func request(parameters: String) -> URLRequest {
        var url = urlComponents([:]).url!
        url = url.appendingPathComponent(parameters)
        return URLRequest(url: url)
    }
    
}

enum NetworkResult<T, U> where U: Error  {
    case success(T)
    case failure(U)
}

enum NetworkError: Error {
    case invalidData
    case jsonConversionFailure
    case jsonParsingFailure
    case responseUnsuccessful
    case requestFailed

    var localizedDescription: String {
        switch self {
        case .invalidData: return "Invalid Data"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        case .requestFailed: return "Request Failed"
        case .responseUnsuccessful: return "Response Unsuccessful"
        }
    }
}

protocol NetworkClient {
    var session: URLSession { get }
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (NetworkResult<T, NetworkError>) -> Void)
}

extension NetworkClient {
    typealias JSONTaskCompletionHandler = (Decodable?, NetworkError?) -> Void
    func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let genericModel = try decoder.decode(decodingType, from: data)
                        completion(genericModel, nil)
                    } catch {
                        print(error)
                        completion(nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, .invalidData)
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
        }
        return task
    }
    
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (NetworkResult<T, NetworkError>) -> Void) {
        let task = decodingTask(with: request, decodingType: T.self) { (json , error) in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(NetworkResult.failure(error))
                    } else {
                        completion(NetworkResult.failure(.invalidData))
                    }
                    return
                }
                if let value = decode(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(.jsonParsingFailure))
                }
            }
        }
        task.resume()
    }
}
