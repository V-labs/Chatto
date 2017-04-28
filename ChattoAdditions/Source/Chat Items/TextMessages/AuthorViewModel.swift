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
    var font: UIFont = UIFont.systemFont(ofSize: 14)
    
    
    init(author: AuthorModelProtocol) {
        self.text = author.name
        if author.speciality == "cardiologist" {
            self.color = UIColor(red: 128.0/255.0, green: 166.0/255.0, blue: 36.0/255.0, alpha: 1)
        } else {
            self.color = UIColor(red: 212.0/255.0, green: 12.0/255.0, blue: 22.0/255.0, alpha: 1)
        }
    }
}
