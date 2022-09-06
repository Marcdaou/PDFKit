//
//  NetworkManager.swift
//  Margaritas PDFKit
//
//  Created by Marc Daou on 9/1/22.
//

import Foundation

class NetworkManager {
    
    static var shared : NetworkManager = NetworkManager()
    
    private let margaritaUrl = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s="
    
    func getCocktails(searchQuery: String, success: @escaping (_ menu: Menu) -> Void, failure: @escaping (_ error: String) -> Void) {
        
        let semaphore = DispatchSemaphore (value: 0)
        
        var request = URLRequest(url: URL(string: "\(margaritaUrl)\(searchQuery)".replacingOccurrences(of: " ", with: ""))!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                failure(error?.localizedDescription ?? "GET error")
                semaphore.signal()
                return
            }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(Menu.self, from: data)
                success(response)
            } catch {
                failure(error.localizedDescription)
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
}
