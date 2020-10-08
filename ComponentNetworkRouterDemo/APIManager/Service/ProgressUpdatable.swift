//
//  ProgressUpdatable.swift
//  ProjectSApp
//
//  Created by 黃柏叡 on 2020/4/23.
//  Copyright © 2020 Frank Chen. All rights reserved.
//

import Foundation

protocol SessionTaskProgressDelegate: class {
    func sessionTask(_ request: RequestUnique, with updateProgress: Double)
}

protocol ProgressUpdatable: class {
    var delegate: SessionTaskProgressDelegate? { get set }
}
