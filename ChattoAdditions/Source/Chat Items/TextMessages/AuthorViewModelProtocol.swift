//
//  AuthorViewModelProtocol.swift
//  Pods
//
//  Created by Rémi Caroff on 28/04/2017.
//
//

import Foundation

public protocol AuthorViewModelProtocol {
    
    var text: String { get set }
    var color: UIColor { get set }
    var font: UIFont { get set }
    
}
