//
//  ReadStatusViewModelProtocol.swift
//  ChattoAdditions
//
//  Created by Kevin on 02/01/2019.
//  Copyright © 2019 Badoo. All rights reserved.
//

import Foundation

public protocol ReadStatusViewModelProtocol {
    var label: String { get set }
    var icon: UIImage { get set }
    var value: ReadStatusValue { get set }
}
