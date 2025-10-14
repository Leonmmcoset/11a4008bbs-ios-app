//
//  ImageRetriever.swift
//  AsyncImageStarter
//
//  Created by Tunde Adegoroye on 09/04/2022.
//

import Foundation

struct ImageRetriver {
    // 创建自定义URLSession配置，使用多线程
    private let session: URLSession
    
    init() {
        // 创建一个配置
        let config = URLSessionConfiguration.default
        
        // 设置并发请求数
        config.httpMaximumConnectionsPerHost = 5
        
        // 创建一个自定义队列用于网络请求
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        operationQueue.qualityOfService = .userInitiated
        
        // 初始化URLSession
        session = URLSession(configuration: config, delegate: nil, delegateQueue: operationQueue)
    }
    
    func fetch(_ imgUrl: String) async throws -> Data {
        guard let url = URL(string: imgUrl) else {
            throw RetriverError.invalidUrl
        }

        let (data, _) = try await session.data(from: url)
        return data
    }
}

private extension ImageRetriver {
    enum RetriverError: Error {
        case invalidUrl
    }
}
