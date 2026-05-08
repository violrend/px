import SwiftUI

// MARK: – Design tokens  (mirrors website CSS :root variables)
enum PF {
    static let bg       = Color(hex: "#f6f7fb")
    static let card     = Color.white
    static let text     = Color(hex: "#0f172a")
    static let muted    = Color(hex: "#64748b")
    static let line     = Color(hex: "#e5e7eb")
    static let orange   = Color(hex: "#f05a28")
    static let orange2  = Color(hex: "#ff6a3d")
    static let radius: CGFloat   = 14
    static let radiusLg: CGFloat = 18
    static let shadow  = Color.black.opacity(0.08)
}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        var val: UInt64 = 0
        Scanner(string: h).scanHexInt64(&val)
        let r = Double((val >> 16) & 0xFF) / 255
        let g = Double((val >> 8)  & 0xFF) / 255
        let b = Double( val        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: – Reusable shadow modifier
extension View {
    func pfShadow() -> some View {
        self.shadow(color: PF.shadow, radius: 10, x: 0, y: 4)
    }
    func pfCard() -> some View {
        self
            .background(PF.card)
            .clipShape(RoundedRectangle(cornerRadius: PF.radius))
            .pfShadow()
    }
}
