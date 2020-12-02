//
//  AddressAPI.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/12/02.
//

import Foundation

final class AddressAPI {
    typealias JsonDict = [String: Any]
    typealias JsonArray = [Any]
    
    enum AddressAPIError: Error {
        case nmfClientError
    }
    
    static var shared = AddressAPI()
    
    func address(lat: Double, lng: Double, completion: ((Result<String, Error>) -> Void)?) {
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
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion?(.failure(error))
                return
            }
            guard let data = data else { return }
            
            completion?(.success(self.parse(data: data)))
        }.resume()
    }
    
    private func parse(data: Data) -> String {
        let areas = ["area1", "area2", "area3", "area4"]
        let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? JsonDict
        let jsonResults = jsonData?["results"] as? JsonArray
        let jsonFirst = jsonResults?[0] as? JsonDict
        let jsonRegion = jsonFirst?["region"] as? JsonDict
        
        return areas.reduce("") { result, area in
            guard let areaName = (jsonRegion?[area] as? [String: Any])?["name"] as? String else { return result }
            return result + " " + areaName
        }
    }
}
