//
//  HomeAssistantDao.swift
//  associate
//
//  Created by Roey Benamotz on 1/23/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import Foundation

class HomeAssistantDao {
    static let shared = HomeAssistantDao()
    static let stateUpdatedEvent = "states-updated"
    static let conectionDetailsUpdatedSuccess = "connection-detailed-updated-success"
    static let conectionDetailsUpdatedFail = "connection-detailed-updated-fail"
    var allStates = [String : HomeAssistantState]()
    var isPaused = true
    var apiBaseURL: String?
    var apiPassword: String?
    private var pollTimer : Timer? = Timer()
    let events = EventManager()
    private var homeAssistantUrl : String?
    private var homeAssistantPassword: String?
    var isConnectionDetailsValid = false
    
    
    private init() {
        let u = UserConfig.shared
        if (u.url == nil) {
            self.isConnectionDetailsValid = false
        } else {
            self.isConnectionDetailsValid = true
            self.apiBaseURL = u.url
            self.apiPassword = u.haAccessPassword
            self.updateData()
            self.isPaused = false
        }
        self.pollTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)


    }
    private func prepareRequest (api: String) -> URLRequest? {
        if (self.apiBaseURL == nil) {
            return nil
        }
        let urlString = self.apiBaseURL! + api
        guard let url = URL(string: urlString) else { return nil}
        var request = URLRequest(url:url)
        if (self.apiPassword != nil) {
            request.setValue(self.apiPassword!, forHTTPHeaderField: "x-ha-access")
        }
        return request

    }
    
    func updateConnectionDetails(newBaseUrl: String, password: String?) {
        self.isPaused = true
        let urlString = newBaseUrl + "/api/"
        let ha = HomeAssistantDao.shared
        guard let url = URL(string: urlString) else {
            self.isPaused = false
            ha.events.trigger(eventName: HomeAssistantDao.conectionDetailsUpdatedFail, information: "URL not valid")
            return
        }
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        if (password != nil) {
            request.setValue(password!, forHTTPHeaderField: "x-ha-access")
        }
        let task = URLSession.shared.dataTask(with: request) {(data: Data?, response: URLResponse?, error: Error?) in
            if (error != nil) {
                ha.events.trigger(eventName: HomeAssistantDao.conectionDetailsUpdatedFail, information: error!.localizedDescription)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 401) {
                    ha.events.trigger(eventName: HomeAssistantDao.conectionDetailsUpdatedFail, information: "Access denied")
                    return
                }
            }
            ha.isConnectionDetailsValid = true
            ha.apiBaseURL = newBaseUrl
            ha.apiPassword = password
            ha.isPaused = false
            ha.events.trigger(eventName: HomeAssistantDao.conectionDetailsUpdatedSuccess)
        }
        task.resume()

    }
    
    
    @objc func updateData()
    {
        if (isPaused) {
            return;
        }
        guard let request = prepareRequest(api: "/api/states") else {return}
        let completionHandler = {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                print ("no data")
                return
            }
            do {
                let temp = try JSONDecoder().decode([HomeAssistantState].self, from: data)
                DispatchQueue.main.async {
                    for s in temp {
                        if (!StateButtonBase.supportedPlatforms.contains(s.platform)) {
                            continue
                        }
                        self.allStates.updateValue(s, forKey: s.entityId)
                    }
                    HomeAssistantDao.shared.events.trigger(eventName: HomeAssistantDao.stateUpdatedEvent)
                }
                
            } catch let jsonError {
                print(jsonError)
            }
        }
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    func runService (domain: String, service: String, entityId: String) {
        let api = "/api/services/" + domain + "/" + service
        guard var request = prepareRequest(api: api) else {return}
        request.httpMethod = "POST"
        let body = "{\"entity_id\" : \"" + entityId + "\"}"
        let task = URLSession.shared.uploadTask(with: request, from:body.data(using: .utf8)) { data, response, error in
            self.isPaused = false
            //            HomeAssistantDao.shared.updateData()
        }
        self.isPaused = true
        task.resume()

    }

}
