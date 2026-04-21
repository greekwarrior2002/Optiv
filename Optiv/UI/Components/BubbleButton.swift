import SwiftUI

struct BubbleButton: View {
    let title: String
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            isSelected.toggle()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .white : OptivTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected ? OptivTheme.accent : OptivTheme.card)
                        .overlay {
                            Capsule().stroke(isSelected ? OptivTheme.accent : OptivTheme.textTertiary.opacity(0.4), lineWidth: 1)
                        }
                }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.72), value: isSelected)
    }
}
