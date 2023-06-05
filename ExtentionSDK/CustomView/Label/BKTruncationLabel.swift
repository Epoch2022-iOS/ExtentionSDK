//
//  BKTruncationLabel.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//


import UIKit

class BKTruncationLabel: UIControl {
    
    var truncationToken: (open: NSAttributedString, close: NSAttributedString) = (NSAttributedString(" 展开") { $0
        .foregroundColor(UIColor.hex("#1F70FF"))
    }, NSAttributedString(" 折叠") { $0
        .foregroundColor(UIColor.hex("#1F70FF"))
    })
    
    var attributedText: NSMutableAttributedString? {
        didSet {
            guard attributedText != oldValue else { return }
            displayAttributedText = attributedText
        }
    }
    
    var isOpen = false
    var numberOfLines: Int = 2
    var contentEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            guard contentEdgeInsets != oldValue else { return }
            mainStackView.layoutMargins = contentEdgeInsets
        }
    }
    
    private var displayAttributedText: NSAttributedString?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(mainStackView)
        mainStackView.addArrangedSubview(textLabel)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lazy
    private(set) lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.isUserInteractionEnabled = false
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.insetsLayoutMarginsFromSafeArea = false
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .zero
        view.spacing = 0
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
}

// MARK: - Public
extension BKTruncationLabel {
    
    func reload() {
        guard let attributedText = attributedText?.addAttributes({ $0.font(textLabel.font) }) else { return }
        guard Thread.isMainThread else { return DispatchQueue.main.async { self.reload() }}
        self.setNeedsLayout()
        self.layoutIfNeeded()
        let width = textLabel.bounds.width
        let lines = attributedText.lines(width)
        if numberOfLines > 0, lines.count >= numberOfLines {
            let additionalAttributedText = isOpen ? truncationToken.close : truncationToken.open
            let length = lines.prefix(numberOfLines).reduce(0, { $0 + CTLineGetStringRange($1).length })
            textLabel.attributedText = additionalAttributedText
            let truncationTokenWidth = textLabel.sizeThatFits(.zero).width
            let maxLength = isOpen ? attributedText.length : min(CTLineGetStringIndexForPosition(lines[numberOfLines-1], CGPoint(x: width-truncationTokenWidth, y: 0)), length) - 1
            displayAttributedText = {
                let attributedText = NSMutableAttributedString(attributedString: attributedText.attributedSubstring(from: NSRange(location: 0, length: maxLength)))
                attributedText.append(additionalAttributedText)
                return attributedText
            }()
        }
        textLabel.attributedText = displayAttributedText
    }
    
}
