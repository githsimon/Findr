//
//  FlowLayout.swift
//  FindrIOS
//
//  Created on 2025/3/15.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentRowWidth + size.width > containerWidth && currentRowWidth > 0 {
                // 开始新的一行
                height += currentRowHeight + spacing
                currentRowWidth = size.width
                currentRowHeight = size.height
            } else {
                // 继续当前行
                currentRowWidth += size.width + (currentRowWidth > 0 ? spacing : 0)
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }
        
        // 添加最后一行的高度
        if currentRowHeight > 0 {
            height += currentRowHeight
        }
        
        return CGSize(width: containerWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                // 开始新的一行
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            // 放置子视图
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            
            // 更新位置和行高
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
