//
//  ViewController.swift
//  ScrollView
//
//  Created by Aleksander Maj on 26/12/2018.
//  Copyright © 2018 DonkeyRepublic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var smallTitleLabel: UILabel!

    private var topBarHeightRange: ClosedRange<CGFloat> = 0...0
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topBarHeightRange = getTopBarHeightRange()
        adjustTopContentInset(topBarHeightRange.upperBound)
        adjustSmallTitleAlpha()
        heightConstraint = stackView.heightAnchor.constraint(equalToConstant: topBarHeightRange.upperBound)
        heightConstraint?.isActive = true
    }

    private func setUp() {
        stackView.isLayoutMarginsRelativeArrangement = true
        scrollView.delegate = self
    }

    private func getTopBarHeightRange() -> ClosedRange<CGFloat> {
        let compactSize = stackView.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .init(rawValue: 710))

        let fullSize = stackView.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .init(rawValue: 690))

        return compactSize.height ... fullSize.height
    }

    private func adjustTopContentInset(_ topInset: CGFloat) {
        scrollView.contentInset.top = topInset
        scrollView.scrollIndicatorInsets.top = topInset
    }

    private func adjustSmallTitleAlpha() {
        smallTitleLabel.alpha = scrollView.contentInset.top > topBarHeightRange.lowerBound
        ? 0
        : 1
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let topInset = (-contentOffsetY).limitedBy(topBarHeightRange)
        adjustTopContentInset(topInset)
        heightConstraint?.constant = topInset
        adjustSmallTitleAlpha()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetY = targetContentOffset.pointee.y
        let snappedTargetY = targetY.snappedTo([topBarHeightRange.lowerBound, topBarHeightRange.upperBound].map(-))
        targetContentOffset.pointee.y = snappedTargetY
        print("Snapped: \(targetY) -> \(snappedTargetY)")
    }
}

extension CGFloat {
    func limitedBy(_ range: ClosedRange<CGFloat>) -> CGFloat {
        return CGFloat.minimum(
            CGFloat.maximum(self, range.lowerBound),
            range.upperBound
        )
    }

    func snappedTo(_ values: [CGFloat]) -> CGFloat {
        let sortedValues = values.sorted()

        guard let first = sortedValues.first,
            let last = sortedValues.last,
            first != last,
            (first...last).contains(self) else { return self }

        let distances = sortedValues
            .map { abs($0 - self) }

        guard let shortest = distances.min() else { return self }

        let result = distances
            .firstIndex(of: shortest)
            .map { sortedValues[$0] }
            ?? self

        return result
    }
}

