import SwiftUI

/// One node on the home map. A tappable circle whose look encodes its state
/// (done / current / available / locked / premium-locked), with the unit's
/// name on the alternating side and earned stars beneath when complete. Nodes
/// are joined by a short connector so the track reads as a single climbing path.
struct UnitNodeView: View {
    enum State { case done, current, available, locked, premiumLocked }
    enum Side { case leading, trailing }

    let unit: Unit
    let state: State
    let stars: Int
    let side: Side
    let isLast: Bool
    let action: () -> Void

    private let circleSize: CGFloat = 82

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                labelSlot(visible: side == .leading, alignment: .trailing)
                circle
                labelSlot(visible: side == .trailing, alignment: .leading)
            }
            if !isLast {
                Rectangle()
                    .fill(Theme.line)
                    .frame(width: 4, height: 30)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Circle

    private var circle: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(fillColor)
                    .overlay { Circle().strokeBorder(strokeColor, lineWidth: 3) }
                    .frame(width: circleSize, height: circleSize)
                    .shadow(color: state == .locked ? .clear : unit.tier.color.opacity(0.25),
                            radius: 6, y: 3)

                Image(systemName: symbol)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(symbolColor)

                if state == .current {
                    Circle()
                        .strokeBorder(unit.tier.color.opacity(0.35), lineWidth: 3)
                        .frame(width: circleSize + 14, height: circleSize + 14)
                }
            }
            .overlay(alignment: .topTrailing) {
                if state == .premiumLocked { crownBadge }
            }
            .overlay(alignment: .bottom) {
                if state == .done { starRow.offset(y: 14) }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityText)
    }

    private var crownBadge: some View {
        Image(systemName: "crown.fill")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 26, height: 26)
            .background(Circle().fill(Theme.spark))
            .overlay(Circle().strokeBorder(Theme.ground, lineWidth: 2))
            .offset(x: 6, y: -4)
    }

    private var starRow: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < stars ? "star.fill" : "star")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(i < stars ? Theme.sprouts : Theme.line)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Capsule().fill(Theme.ground2))
        .shadow(color: Theme.ink.opacity(0.08), radius: 2, y: 1)
    }

    // MARK: Label

    private var dimmed: Bool { state == .locked || state == .premiumLocked }

    private func labelSlot(visible: Bool, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 3) {
            if visible {
                Text(unit.title)
                    .font(.sprocket(16, .bold))
                    .foregroundStyle(dimmed ? Theme.inkFaint : Theme.ink)
                    .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
                Text(subtitleText)
                    .font(.sprocket(12, .medium))
                    .foregroundStyle(state == .premiumLocked ? Theme.spark : Theme.inkFaint)
                    .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
    }

    private var subtitleText: String {
        switch state {
        case .locked:        return "Locked"
        case .premiumLocked: return "Sprocket Plus"
        default:             return "\(unit.subtitle) · \(unit.minutes) min"
        }
    }

    // MARK: State → look

    private var fillColor: Color {
        switch state {
        case .done, .current: return unit.tier.color
        case .available:      return Theme.ground2
        case .premiumLocked:  return unit.tier.softColor
        case .locked:         return Theme.ground3
        }
    }
    private var strokeColor: Color {
        switch state {
        case .done, .current: return unit.tier.color
        case .available:      return unit.tier.color.opacity(0.5)
        case .premiumLocked:  return unit.tier.color.opacity(0.6)
        case .locked:         return Theme.line
        }
    }
    private var symbolColor: Color {
        switch state {
        case .done, .current: return .white
        case .available:      return unit.tier.color
        case .premiumLocked:  return unit.tier.color
        case .locked:         return Theme.inkFaint
        }
    }
    private var symbol: String {
        switch state {
        case .done:                    return "checkmark"
        case .locked, .premiumLocked:  return "lock.fill"
        default:                       return unit.symbol
        }
    }

    private var accessibilityText: String {
        switch state {
        case .done:          return "\(unit.title), completed, \(stars) of 3 stars"
        case .current:       return "\(unit.title), start this next"
        case .available:     return "\(unit.title), available"
        case .locked:        return "\(unit.title), locked"
        case .premiumLocked: return "\(unit.title), unlock with Sprocket Plus"
        }
    }
}
