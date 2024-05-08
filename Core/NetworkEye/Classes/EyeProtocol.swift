//
//  EyeProtocol.swift
//  Pods
//
//  Created by zixun on 16/12/25.
//
//

import Foundation

class EyeProtocol: URLProtocol {
    
    class func open() {
        URLProtocol.registerClass(classForCoder())
    }
    
    class func close() {
        URLProtocol.unregisterClass(classForCoder())
    }
    
    public class func add(delegate:NetworkEyeDelegate) {
        // delete null week delegate
        delegates = delegates.filter { $0.delegate != nil }

        // judge if contains the delegate from parameter
        let contains = delegates.contains { $0.delegate?.hash == delegate.hash }
        // if not contains, append it with weak wrapped
        if !contains {
            let week = WeakNetworkEyeDelegate(delegate: delegate)
            delegates.append(week)
        }
    }
    
    public class func remove(delegate:NetworkEyeDelegate) {
        delegates = delegates
            .filter {
                // filter null weak delegate
                $0.delegate != nil
            }
            .filter {
                // filter the delegate from parameter
                $0.delegate?.hash != delegate.hash
            }
    }
    
    fileprivate var connection: NSURLConnection?

    fileprivate var ca_request: URLRequest?
    fileprivate var ca_response: URLResponse?
    fileprivate var ca_data:Data?
    
    fileprivate static let AppNetworkGreenCard = "AppNetworkGreenCard"
    
    private(set) static  var delegates = [WeakNetworkEyeDelegate]()
    
}

extension EyeProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        guard let scheme = request.url?.scheme else { return false }
        guard scheme == "http" || scheme == "https" else { return false }
        guard URLProtocol.property(forKey: AppNetworkGreenCard, in: request) == nil else { return false }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        guard let req = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else { return .init(url: .init(fileReferenceLiteralResourceName: "")) }
        URLProtocol.setProperty(true, forKey: AppNetworkGreenCard, in: req)
        guard let request = req.copy() as? URLRequest else { return .init(url: .init(fileReferenceLiteralResourceName: "")) }
        return request
    }
    
    override func startLoading() {
        let request = EyeProtocol.canonicalRequest(for: request)
        connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        ca_request = request
    }
    
    override func stopLoading() {
        connection?.cancel()
        EyeProtocol.delegates.forEach {
            $0.delegate?.networkEyeDidCatch(with: ca_request, response: ca_response, data: ca_data)
        }
    }
}

extension EyeProtocol: NSURLConnectionDelegate {
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    func connectionShouldUseCredentialStorage(_ connection: NSURLConnection) -> Bool {
        true
    }
    
    func connection(_ connection: NSURLConnection, didReceive challenge: URLAuthenticationChallenge) {
        client?.urlProtocol(self, didReceive: challenge)
    }
    
    func connection(_ connection: NSURLConnection, didCancel challenge: URLAuthenticationChallenge) {
        client?.urlProtocol(self, didCancel: challenge)
    }
}

extension EyeProtocol: NSURLConnectionDataDelegate {
    func connection(_ connection: NSURLConnection, willSend request: URLRequest, redirectResponse response: URLResponse?) -> URLRequest? {
        if let response = response {
            ca_response = response
            client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        }
        return request
    }
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        ca_response = response
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        if ca_data == nil {
            ca_data = data
        } else {
            ca_data?.append(data)
        }
    }
    
    func connection(_ connection: NSURLConnection, willCacheResponse cachedResponse: CachedURLResponse) -> CachedURLResponse? {
        cachedResponse
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        client?.urlProtocolDidFinishLoading(self)
    }
}
