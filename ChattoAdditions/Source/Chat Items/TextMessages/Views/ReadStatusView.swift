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

    func textFont(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIFont
    func textColor(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIColor
    func textInsets(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIEdgeInsets
}

public final class ReadStatusView: UIView, MaximumLayoutWidthSpecificable, BackgroundSizingQueryable {

    public var preferredMaxLayoutWidth: CGFloat = 0
    public var animationDuration: CFTimeInterval = 0.33
    public var viewContext: ViewContext = .normal // {
//        didSet {
//            if self.viewContext == .sizing {
//                self.textView.dataDetectorTypes = UIDataDetectorTypes()
//                self.textView.isSelectable = false
//            } else {
//                self.textView.dataDetectorTypes = .all
//                self.textView.isSelectable = true
//            }
//        }
//    }

    public var style: TextBubbleViewStyleProtocol! {
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
    }

    private var label: UILabel = {
        let label = UILabel()
//        let textView = ChatMessageTextView()
//        UIView.performWithoutAnimation({ () -> Void in
//             fixes iOS 8 blinking when cell appears
//            textView.backgroundColor = UIColor.clear
//        })
//        textView.isEditable = false
//        textView.isSelectable = true
//        textView.dataDetectorTypes = .all
//        textView.scrollsToTop = false
//        textView.isScrollEnabled = false
//        textView.bounces = false
//        textView.bouncesZoom = false
//        textView.showsHorizontalScrollIndicator = false
//        textView.showsVerticalScrollIndicator = false
//        textView.isExclusiveTouch = true
//        textView.textContainer.lineFragmentPadding = 0
//        textView.text = "Lu par tout le monde"
        label.text = "Lu par tout le monde"
        label.textColor = .orange
        return label
    }()

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

        let font = UIFont(name: "Montserrat-regular", size: 12)!
        let textColor = UIColor.orange

        var needsToUpdateText = false

        if self.label.font != font {
            self.label.font = font
            needsToUpdateText = true
        }

        if self.label.textColor != textColor {
            self.label.textColor = textColor
//            self.label.linkTextAttributes = [
//                NSAttributedString.Key.foregroundColor: textColor,
//                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
//            ]
            needsToUpdateText = true
        }

//        let textInsets = style.textInsets(viewModel: viewModel, isSelected: false)
//    let textInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//        if self.label.textContainerInset != textInsets {
//            self.label.textContainerInset = textInsets
//        }
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.calculateReadStatusLayout(preferredMaxLayoutWidth: size.width).size
    }

    // MARK: Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        let layout = self.calculateReadStatusLayout(preferredMaxLayoutWidth: self.preferredMaxLayoutWidth)
        self.label.bma_rect = layout.textFrame
    }

    public var layoutCache: NSCache<AnyObject, AnyObject>!

    private func calculateReadStatusLayout(preferredMaxLayoutWidth: CGFloat) -> ReadStatusLayoutModel {
        let layoutContext = ReadStatusLayoutModel.LayoutContext(
                text: "Lu par tout le monde",
                font: .systemFont(ofSize: 12),
                textInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
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
        let textHorizontalInset = self.layoutContext.textInsets.bma_horziontalInset
        let maxTextWidth = self.layoutContext.preferredMaxLayoutWidth - textHorizontalInset

        var textSizeWidth = self.textSizeThatFitsWidth(maxTextWidth).width

        let textSize = CGSize(width: textSizeWidth, height: self.textSizeThatFitsWidth(maxTextWidth).height)
        self.textFrame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
        self.size = textSize
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
