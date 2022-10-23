//
//  Data+Ext.swift
//  InstabugNetworkClient
//
//  Created by AlaaElrhman on 22/10/2022.
//

import Foundation

extension Data{
    func dataSizeInMB() -> Double {
        var size: Double = 0.0
        if Double(self.count) > 0.0 {
            size = (Double(self.count) / (1024 * 1024))
        }
        return size
    }
}
