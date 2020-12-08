//
//  AddressAPI.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/12/02.
//

import Foundation

protocol AddressAPIService {
    func address(lat: Double, lng: Double, completion: ((Result<Data, Error>) -> Void)?) -> URLSessionDataTask?
}

final class AddressAPI: AddressAPIService {
    enum AddressAPIError: Error {
        case nmfClientError
    }
    private let addressCache = NSCache<NSURL, NSData>()
    
    let NMFClientId = "NMFClientId"
    let NMFClientSecret = "NMFClientSecret"
    
    let apiKeyID = "X-NCP-APIGW-API-KEY-ID"
    let apiKey = "X-NCP-APIGW-API-KEY"

    private func url(lat: Double, lng: Double) -> URL? {
        var components = URLComponents(string: "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc")
        let coords = URLQueryItem(name: "coords", value: "\(lng),\(lat)")
        let output = URLQueryItem(name: "output", value: "json")
        let orders = URLQueryItem(name: "orders", value: "roadaddr")
        
        components?.queryItems = [coords, output, orders]
        return components?.url
    }
    
    func address(lat: Double, lng: Double, completion: ((Result<Data, Error>) -> Void)?) -> URLSessionDataTask? {
        guard let url = url(lat: lat, lng: lng),
              let id = Bundle.main.infoDictionary?[NMFClientId] as? String,
              let secret = Bundle.main.infoDictionary?[NMFClientSecret] as? String else {
            completion?(.failure(AddressAPIError.nmfClientError))
            return nil
        }
        
        // check cached address
        if let cached = addressCache.object(forKey: url as NSURL) {
            completion?(.success(cached as Data))
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.allHTTPHeaderFields = [
            "X-NCP-APIGW-API-KEY-ID": id,
            "X-NCP-APIGW-API-KEY": secret
        ]
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion?(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    completion?(.failure(AddressAPIError.nmfClientError))
                    debugPrint(response ?? "")
                    return
                }
                
                guard let data = data else { return }
                
                self.addressCache.setObject(data as NSData, forKey: url as NSURL)
                completion?(.success(data))
            }
        }
        
        task.resume()
        return task
    }
}
