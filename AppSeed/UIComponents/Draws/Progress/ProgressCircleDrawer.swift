//
//  ProgressCircleDrawer.swift
//  AppSeed
//
//  Created by tunay alver on 20.10.2023.
//

import UIKit

public class ProgressCircleDrawer : NSObject {

    //// Drawing Methods
    @objc dynamic public class func draw(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 84, height: 84),
                                         resizing: ResizingBehavior = .aspectFit,
                                         progress: CGFloat = 1,
                                         timeString: String? = "",
                                         colorBackgroundCircle: UIColor = .systemGray,
                                         colorCircle: UIColor = .systemGreen) {
        //// General
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 80, height: 80), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 80, y: resizedFrame.height / 80)

        //// Variable
        let gapLine: CGFloat = CGFloat.pi * 75
        let dash: CGFloat = gapLine - (progress * gapLine)

        //// Line
        context.saveGState()
        context.translateBy(x: 40, y: 40)

        let ovalPath = UIBezierPath(ovalIn: CGRect(x: -37.5, y: -37.5, width: 75, height: 75))
        colorBackgroundCircle.setStroke()
        ovalPath.lineWidth = 3
        ovalPath.lineCapStyle = .round
        ovalPath.lineJoinStyle = .round
        ovalPath.stroke()
        context.restoreGState()
        
        //// Background Line
        context.saveGState()
        context.translateBy(x: 40, y: 40)
        context.rotate(by: -90 * CGFloat.pi/180)
        
        let oval2Path = UIBezierPath(ovalIn: CGRect(x: -37.5, y: -37.5, width: 75, height: 75))
        colorCircle.setStroke()
        oval2Path.lineWidth = 5
        oval2Path.lineCapStyle = .round
        oval2Path.lineJoinStyle = .round
        context.saveGState()
        context.setLineDash(phase: 0, lengths: [dash, gapLine])
        oval2Path.stroke()
        context.restoreGState()
        
        context.restoreGState()
        
        //// Text
        let textRect = CGRect(x: 8, y: 28, width: 64, height: 24)
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let textFontAttributes = [
            .font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular),
            .foregroundColor: UIColor.systemYellow,
            .paragraphStyle: textStyle,
        ] as [NSAttributedString.Key: Any]

        let textTextHeight: CGFloat = timeString?.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity),
                                                               options: .usesLineFragmentOrigin,
                                                               attributes: textFontAttributes,
                                                               context: nil).height ?? 0
        context.saveGState()
        context.clip(to: textRect)
        timeString?.draw(in: CGRect(x: textRect.minX,
                                    y: textRect.minY + (textRect.height - textTextHeight) / 2,
                                    width: textRect.width,
                                    height: textTextHeight),
                         withAttributes: textFontAttributes)
        context.restoreGState()
        
        context.restoreGState()
    }

    @objc(ProgressStudyResizingBehavior)
    public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
