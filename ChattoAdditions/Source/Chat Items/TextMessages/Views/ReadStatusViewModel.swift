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
    var text: String { get set }
}

public class ReadStatusViewModel: ReadStatusViewModelProtocol {
    public var text: String = ""

    public init(text: String) {
        self.text = text
    }
}
