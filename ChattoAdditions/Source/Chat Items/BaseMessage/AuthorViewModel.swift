//
//  AuthorMessageViewModel.swift
//  iCrac
//
//  Created by Rémi Caroff on 28/04/2017.
//  Copyright © 2017 Crac. All rights reserved.
//

import UIKit

class AuthorViewModel: NSObject, AuthorViewModelProtocol {
    
    var text: String = ""
    var color: UIColor = UIColor.gray
    var font: UIFont = UIFont.boldSystemFont(ofSize: 14)
    
    
    init(author: AuthorModelProtocol) {
        self.text = author.name
        self.color = author.color
    }
}
