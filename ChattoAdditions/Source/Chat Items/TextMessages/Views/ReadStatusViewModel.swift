//
// Created by Arthur Guillaume on 2018-12-10.
//

import Foundation

public enum ReadStatusValue {
    case none
    case some(people: [String])
    case all
}

public protocol ReadStatusViewModelProtocol {
    var delegate: ReadStatusViewModelDelegate? { get set }
    var value: ReadStatusValue { get set }
}

public protocol ReadStatusViewModelDelegate {
    func getText(value: ReadStatusValue) -> String
    func getImage(value: ReadStatusValue) -> UIImage
}

public class ReadStatusViewModel: ReadStatusViewModelProtocol {

    public var value: ReadStatusValue = .none
    public var delegate: ReadStatusViewModelDelegate?

    public init(value: ReadStatusValue, delegate: ReadStatusViewModelDelegate) {
        self.value = value
        self.delegate = delegate
    }
}
