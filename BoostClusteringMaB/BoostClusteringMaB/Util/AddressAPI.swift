//
//  AddressAPI.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/12/02.
//

import Foundation

protocol AddressAPIService {
    func address(lat: Double, lng: Double, completion: ((Result<Data, Error>) -> Void)?)
}

final class AddressAPI: AddressAPIService {
    enum AddressAPIError: Error {
        case nmfClientError
    }
    
    func address(lat: Double, lng: Double, completion: ((Result<Data, Error>) -> Void)?) {
        let baseURL = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
        guard let url = URL(string: "\(baseURL)?coords=\(lng),\(lat)&output=json&orders=roadaddr") else { return }
        guard let id = Bundle.main.infoDictionary?["NMFClientId"] as? String,
              let secret = Bundle.main.infoDictionary?["NMFClientSecret"] as? String
        else { completion?(.failure(AddressAPIError.nmfClientError)); return }
        
        var request = URLRequest(url: url)
        
        request.allHTTPHeaderFields = [
            "X-NCP-APIGW-API-KEY-ID": id,
            "X-NCP-APIGW-API-KEY": secret
        ]
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                completion?(.failure(AddressAPIError.nmfClientError))
                debugPrint(response)
                return
            }
            
            guard let data = data else { return }
            
            completion?(.success(data))
        }.resume()
    }
}
