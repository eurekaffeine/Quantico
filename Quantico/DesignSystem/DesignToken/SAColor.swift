//
//  SAColor.swift
//  
//
//  Created by tianpli on 2023/9/26.
//

import Foundation
import SwiftUI

public enum SAColor: CaseIterable, Sendable {
    case surfaceCanvas
    case surfaceBrandPrimary
    case surfaceBrandSecondary
    case surfaceBrandTertiary
    case surfacePrimary
    case surfaceSecondary
    case surfaceTertiary
    case surfaceQuaternary
    case surfaceSuccess
    case surfaceSevere
    case surfaceDanger
    case surfaceInput
    
    case textBrandPrimary
    case textBrandSecondary
    case textBrandDisabled
    case textOnBrand
    case textPrimary
    case textSecondary
    case textTertiary
    case textSevere
    case textSuccess
    case textDanger
    case textDisabled
    
    case borderBrandPrimary
    case borderBrandSecondary
    case borderDanger
    case borderDisabled
    case borderPrimary
    case borderSevere
    case borderSuccess
    case dividerPrimary
    case dividerSecondary
    case dividerTeriary

    case iconPrimary
    case iconSecondary
    case iconTertiary
    case iconBrandDisabled
    case iconBrandPrimary
    case iconBrandSecondary
    case iconDanger
    case iconDisabled
    case iconOnBrand
    case iconSevere
    case iconSuccess
    
    case secondaryDanger
    case secondarySuccess
    case secondarySevere
    case secondaryWarning
    
    case clear
}

extension SAColor {
    internal static let colorMap: [SAColor: [SATheme: GlobalColor]] = [
        .surfaceCanvas: [.light: .grey96, .dark: .grey8],
        .surfacePrimary: [.light: .white, .dark: .black],
        .surfaceSecondary: [.light: .white, .dark: .grey12],
        .surfaceTertiary: [.light: .grey94, .dark: .grey16],
        .surfaceQuaternary: [.light: .grey84, .dark: .grey20],
        .surfaceBrandPrimary: [.light: .brand80, .dark: .brand100],
        .surfaceBrandSecondary: [.light: .brand70, .dark: .brand120],
        .surfaceBrandTertiary: [.light: .brand150, .dark: .brand75],
        .surfaceDanger: [.light: .redTint60, .dark: .redShade40],
        .surfaceSuccess: [.light: .greenTint60, .dark: .greenShade40],
        .surfaceSevere: [.light: .darkOrangeTint60, .dark: .darkOrangeShade40],
        .surfaceInput: [.light: .blackOpacity05, .dark: .whiteOpacity10],
        
        .textPrimary: [.light: .grey12, .dark: .white],
        .textSecondary: [.light: .grey38, .dark: .grey84],
        .textTertiary: [.light: .grey50, .dark: .grey62],
        .textDisabled: [.light: .grey74, .dark: .grey38],
        .textOnBrand: [.light: .white, .dark: .black],
        .textBrandPrimary: [.light: .brand80, .dark: .brand100],
        .textBrandSecondary: [.light: .brand70, .dark: .brand120],
        .textBrandDisabled: [.light: .brand100, .dark: .brand80],
        .textDanger: [.light: .redShade10, .dark: .redTint30],
        .textSuccess: [.light: .greenShade10, .dark: .greenTint30],
        .textSevere: [.light: .darkOrangeShade10, .dark: .darkOrangeTint30],
        
        .dividerPrimary: [.light: .grey94, .dark: .grey20],
        .dividerSecondary: [.light: .grey84, .dark: .grey30],
        .dividerTeriary: [.light: .grey38, .dark: .grey62],
        .borderPrimary: [.light: .white, .dark: .black],
        .borderDisabled: [.light: .grey84, .dark: .grey24],
        .borderBrandPrimary: [.light: .brand80, .dark: .brand100],
        .borderBrandSecondary: [.light: .brand70, .dark: .brand120],
        .borderDanger: [.light: .redTint10, .dark: .redTint30],
        .borderSuccess: [.light: .greenTint10, .dark: .greenTint30],
        .borderSevere: [.light: .darkOrangeTint10, .dark: .darkOrangeTint30],
        
        .iconPrimary: [.light: .grey12, .dark: .white],
        .iconSecondary: [.light: .grey38, .dark: .grey84],
        .iconTertiary: [.light: .grey50, .dark: .grey62],
        .iconDisabled: [.light: .grey74, .dark: .grey38],
        .iconOnBrand: [.light: .white, .dark: .black],
        .iconBrandPrimary: [.light: .brand80, .dark: .brand100],
        .iconBrandSecondary: [.light: .brand70, .dark: .brand120],
        .iconBrandDisabled: [.light: .brand100, .dark: .brand80],
        .iconDanger: [.light: .redShade10, .dark: .redTint30],
        .iconSuccess: [.light: .greenShade10, .dark: .greenTint30],
        .iconSevere: [.light: .darkOrangeShade10, .dark: .darkOrangeTint30],
        .secondaryDanger: [.light: .redPrimary, .dark: .redShade10],
        .secondarySuccess: [.light: .greenPrimary, .dark: .greenShade10],
        .secondarySevere: [.light: .darkOrangePrimary, .dark: .darkOrangeShade10],
        .secondaryWarning: [.light: .yellowPrimary, .dark: .yellowShadow10],
        
        
        .clear: [.light: .clear, .dark: .clear]
    ]
}

@available(iOS, introduced: 17.0)
extension SAColor: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        globalColor(for: environment.saTheme).color
    }
}
