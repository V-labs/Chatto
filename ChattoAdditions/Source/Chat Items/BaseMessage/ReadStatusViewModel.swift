//
//  ReadStatusViewModel.swift
//  ChattoAdditions
//
//  Created by Kevin on 02/01/2019.
//  Copyright © 2019 Badoo. All rights reserved.
//

import Foundation

public class ReadStatusViewModel: NSObject, ReadStatusViewModelProtocol {
    
    public var value: ReadStatusValue = .none
    public var label: String
    public var icon: UIImage
    
    public init(model: ReadStatusModelProtocol) {
        self.value = model.value
        self.label = model.label
        self.icon = model.icon
    }
}
