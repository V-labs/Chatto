/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit
import Chatto

public protocol ReadStatusViewStyleProtocol {

    var font: UIFont { get set }
    var textColor: UIColor { get set }
    var textInsets: UIEdgeInsets { get set }
}

public final class ReadStatusView: UIView, MaximumLayoutWidthSpecificable, BackgroundSizingQueryable {

    public var preferredMaxLayoutWidth: CGFloat = 0
    public var animationDuration: CFTimeInterval = 0.33
    public var viewContext: ViewContext = .normal

    public var style: ReadStatusViewStyleProtocol! {
        didSet {
            self.updateViews()
        }
    }

    public var readStatusViewModel: ReadStatusViewModelProtocol! {
        didSet {
            self.updateViews()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.addSubview(self.label)
        self.addSubview(self.checkMarkView)
    }

    private var _label: UILabel?
    private var label: UILabel {
        if self._label == nil {
            self._label = UILabel(frame: .zero)
        }
        if let viewModel = self.readStatusViewModel {
            self._label!.text = viewModel.delegate?.getText(value: viewModel.value)
        }
        return self._label!
    }

    private var _checkMarkView: UIImageView?
    private var checkMarkView: UIImageView {
        if self._checkMarkView == nil {
            self._checkMarkView = UIImageView(frame: .zero)
        }
        if let viewModel = self.readStatusViewModel {
            self._checkMarkView!.image = viewModel.delegate?.getImage(value: viewModel.value)
        }
        return self._checkMarkView!
    }

    public private(set) var isUpdating: Bool = false

    public func performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() -> Void)?) {
        self.isUpdating = true
        let updateAndRefreshViews = {
            updateClosure()
            self.isUpdating = false
            self.updateViews()
            if animated {
                self.layoutIfNeeded()
            }
        }
        if animated {
            UIView.animate(withDuration: self.animationDuration, animations: updateAndRefreshViews, completion: { (_) -> Void in
                completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }

    private func updateViews() {
        if self.viewContext == .sizing {
            return
        }
        if isUpdating {
            return
        }
        guard let style = self.style else {
            return
        }

        self.updateTextView()
    }

    private func updateTextView() {
        guard let style = self.style else {
            return
        }

        var needsToUpdateText = false

        let font = self.style.font

        if self.label.font != font {
            self.label.font = font
            needsToUpdateText = true
        }

        let textColor = self.style.textColor

        if self.label.textColor != textColor {
            self.label.textColor = textColor
            needsToUpdateText = true
        }

        let text = self.readStatusViewModel.delegate?.getText(value: self.readStatusViewModel.value)
        if text != self.label.text {
            self.label.text = text
            needsToUpdateText = true
        }

        let image = self.readStatusViewModel.delegate?.getImage(value: self.readStatusViewModel.value)
        if image != self.checkMarkView.image {
            self.checkMarkView.image = image
            needsToUpdateText = true
        }

        if needsToUpdateText {
            self.setNeedsLayout()
        }

        self.layoutSubviews()
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.calculateReadStatusLayout(preferredMaxLayoutWidth: size.width).size
    }

    // MARK: Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        let layout = self.calculateReadStatusLayout(preferredMaxLayoutWidth: self.preferredMaxLayoutWidth)
        self.label.bma_rect = layout.textFrame
        self.checkMarkView.bma_rect = layout.checkFrame
    }

    public var layoutCache: NSCache<AnyObject, AnyObject>!

    private func calculateReadStatusLayout(preferredMaxLayoutWidth: CGFloat) -> ReadStatusLayoutModel {
        let layoutContext = ReadStatusLayoutModel.LayoutContext(
                text: self.readStatusViewModel.delegate?.getText(value: self.readStatusViewModel.value) ?? "",
                font: self.style.font,
                textInsets: self.style.textInsets,
                preferredMaxLayoutWidth: preferredMaxLayoutWidth
        )

        if let layoutModel = self.layoutCache?.object(forKey: layoutContext.hashValue as AnyObject) as? ReadStatusLayoutModel, layoutModel.layoutContext == layoutContext {
            return layoutModel
        }

        let layoutModel = ReadStatusLayoutModel(layoutContext: layoutContext)
        layoutModel.calculateLayout()

        self.layoutCache.setObject(layoutModel, forKey: layoutContext.hashValue as AnyObject)
        return layoutModel
    }

    public var canCalculateSizeInBackground: Bool {
        return true
    }
}

private final class ReadStatusLayoutModel {
    let layoutContext: LayoutContext
    var textFrame: CGRect = CGRect.zero
    var checkFrame: CGRect = CGRect.zero
    var size: CGSize = CGSize.zero

    init(layoutContext: LayoutContext) {
        self.layoutContext = layoutContext
    }

    struct LayoutContext: Equatable, Hashable {
        let text: String
        let font: UIFont
        let textInsets: UIEdgeInsets
        let preferredMaxLayoutWidth: CGFloat

        var hashValue: Int {
            return Chatto.bma_combine(hashes: [self.text.hashValue, self.textInsets.bma_hashValue, self.preferredMaxLayoutWidth.hashValue, self.font.hashValue])
        }

        static func ==(lhs: ReadStatusLayoutModel.LayoutContext, rhs: ReadStatusLayoutModel.LayoutContext) -> Bool {
            let lhsValues = (lhs.text, lhs.textInsets, lhs.font, lhs.preferredMaxLayoutWidth)
            let rhsValues = (rhs.text, rhs.textInsets, rhs.font, rhs.preferredMaxLayoutWidth)
            return lhsValues == rhsValues
        }
    }

    func calculateLayout() {
        let padding: CGFloat = 8.0
        let margin: CGFloat = 16.0

        let textHorizontalInset = self.layoutContext.textInsets.bma_horziontalInset
        let maxTextWidth = self.layoutContext.preferredMaxLayoutWidth - textHorizontalInset

        var textSizeWidth = self.textSizeThatFitsWidth(maxTextWidth).width

        let textSize = CGSize(width: textSizeWidth, height: self.textSizeThatFitsWidth(maxTextWidth).height)
        self.textFrame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
        self.checkFrame = CGRect(x: self.textFrame.width + padding, y: self.textFrame.height / 2 - 4, width: 8, height: 8)
        self.size = CGSize(width: textSize.width + padding + checkFrame.width + margin, height: max(textSize.height, checkFrame.height))
    }

    private func textSizeThatFitsWidth(_ width: CGFloat) -> CGSize {
        let textContainer: NSTextContainer = {
            let size = CGSize(width: width, height: .greatestFiniteMagnitude)
            let container = NSTextContainer(size: size)
            container.lineFragmentPadding = 0
            return container
        }()

        let textStorage = self.replicateUITextViewNSTextStorage()
        let layoutManager: NSLayoutManager = {
            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            return layoutManager
        }()

        let rect = layoutManager.usedRect(for: textContainer)
        return rect.size.bma_round()
    }

    private func replicateUITextViewNSTextStorage() -> NSTextStorage {
        // See https://github.com/badoo/Chatto/issues/129
        return NSTextStorage(string: self.layoutContext.text, attributes: [
            NSAttributedString.Key.font: self.layoutContext.font,
            NSAttributedString.Key(rawValue: "NSOriginalFont"): self.layoutContext.font
        ])
    }
}

/// UITextView with hacks to avoid selection, loupe, define...
private final class ChatMessageTextView: UITextView {

    override var canBecomeFirstResponder: Bool {
        return false
    }

    // See https://github.com/badoo/Chatto/issues/363
    override var gestureRecognizers: [UIGestureRecognizer]? {
        set {
            super.gestureRecognizers = newValue
        }
        get {
            return super.gestureRecognizers?.filter({ (gestureRecognizer) -> Bool in
                return type(of: gestureRecognizer) == UILongPressGestureRecognizer.self && gestureRecognizer.delaysTouchesEnded
            })
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    override var selectedRange: NSRange {
        get {
            return NSRange(location: 0, length: 0)
        }
        set {
            // Part of the heaviest stack trace when scrolling (when updating text)
            // See https://github.com/badoo/Chatto/pull/144
        }
    }

    override var contentOffset: CGPoint {
        get {
            return .zero
        }
        set {
            // Part of the heaviest stack trace when scrolling (when bounds are set)
            // See https://github.com/badoo/Chatto/pull/144
        }
    }
}
