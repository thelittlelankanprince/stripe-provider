//
//  SourceRoutes.swift
//  Stripe
//
//  Created by Andrew Edwards on 6/1/17.
//
//

import Vapor

public protocol SourceRoutes {
    associatedtype S: Source
    associatedtype M: Mandate
    associatedtype O: Owner
    
    func create(type: SourceType, amount: Int?, currency: StripeCurrency?, flow: Flow?, mandate: M?, metadata: [String: String]?, owner: O?, receiver: [String: String]?, redirect: [String: String]?, statementDescriptor: String?, token: String?, usage: String?) throws -> Future<S>
    func retrieve(source: String, clientSecret: String?) throws -> Future<S>
    func update(source: String, mandate: M?, metadata: [String: String]?, owner: O?) throws -> Future<S>
}

public struct StripeSourceRoutes: SourceRoutes {
    private let request: StripeRequest
    
    init(request: StripeRequest) {
        self.request = request
    }

    /// Create a source
    /// [Learn More →](https://stripe.com/docs/api/curl#create_source)
    public func create(type: SourceType,
                       amount: Int? = nil,
                       currency: StripeCurrency? = nil,
                       flow: Flow? = nil,
                       mandate: StripeMandate? = nil,
                       metadata: [String : String]? = nil,
                       owner: StripeOwner? = nil,
                       receiver: [String : String]? = nil,
                       redirect: [String : String]? = nil,
                       statementDescriptor: String? = nil,
                       token: String? = nil,
                       usage: String? = nil) throws -> Future<StripeSource> {
        var body: [String: Any] = [:]
        
        body["type"] = type.rawValue
        
        if let currency = currency {
            body["currency"] = currency.rawValue
        }
        
        if let flow = flow {
            body["flow"] = flow.rawValue
        }
        
        if let mandate = mandate {
            try mandate.toEncodedDictionary().forEach { body["mandate[\($0)]"] = $1 }
        }
        
        if let metadata = metadata {
            metadata.forEach { body["metadata[\($0)]"] = $1 }
        }
        
        if let owner = owner {
            try owner.toEncodedDictionary().forEach { body["owner[\($0)]"] = $1 }
        }
        
        if let receiver =  receiver {
            receiver.forEach { body["receiver[\($0)]"] = $1 }
        }
        
        if let redirect = redirect {
            redirect.forEach { body["redirect[\($0)]"] = $1 }
        }
        
        if let statementDescriptor = statementDescriptor {
            body["statement_descriptor"] = statementDescriptor
        }
        
        if let token = token {
            body["token"] = token
        }
        
        if let usage = usage {
            body["usage"] = usage
        }
        
        return try request.send(method: .POST, path: StripeAPIEndpoint.sources.endpoint, body: body.queryParameters)
    }
    
    /// Retrieve a source
    /// [Learn More →](https://stripe.com/docs/api/curl#retrieve_source)
    public func retrieve(source: String, clientSecret: String?) throws -> Future<StripeSource> {
        var query = ""
        if let clientSecret = clientSecret {
            query = "client_secret=\(clientSecret)" 
        }
        
        return try request.send(method: .GET, path: StripeAPIEndpoint.source(source).endpoint, query: query)
    }
    
    /// Update a source
    /// [Learn More →](https://stripe.com/docs/api/curl#update_source)
    public func update(source: String,
                       mandate: StripeMandate? = nil,
                       metadata: [String : String]? = nil,
                       owner: StripeOwner? = nil) throws -> Future<StripeSource> {
        var body: [String: Any] = [:]
        
        if let mandate = mandate {
            try mandate.toEncodedDictionary().forEach { body["mandate[\($0)]"] = $1 }
        }
        
        if let metadata = metadata {
            metadata.forEach { body["metadata[\($0)]"] = $1 }
        }
        
        if let owner = owner {
            try owner.toEncodedDictionary().forEach { body["owner[\($0)]"] = $1 }
        }
        
        return try request.send(method: .POST, path: StripeAPIEndpoint.source(source).endpoint, body: body.queryParameters)
    }
}
