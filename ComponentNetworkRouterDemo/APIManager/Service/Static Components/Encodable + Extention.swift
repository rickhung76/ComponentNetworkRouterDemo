//
//  Encodable + Extention.swift
//  ZXFast_iOS
//
//  Created by 黃柏叡 on 2019/10/3.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
