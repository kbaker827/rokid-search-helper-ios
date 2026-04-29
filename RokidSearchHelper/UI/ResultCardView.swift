import SwiftUI

struct ResultCardView: View {
    let query: String
    let answer: String
    let source: String
    let fontSize: Double
    let highContrast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question
            Label(query, systemImage: "questionmark.circle.fill")
                .font(.system(size: fontSize * 0.75, weight: .semibold))
                .foregroundStyle(highContrast ? .white : .secondary)
                .lineLimit(3)

            Divider()
                .background(highContrast ? Color.white.opacity(0.3) : Color.secondary.opacity(0.3))

            // Answer
            Text(answer)
                .font(.system(size: fontSize, weight: .medium))
                .foregroundStyle(highContrast ? .white : .primary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)

            // Source badge
            HStack {
                Spacer()
                Text(source)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(highContrast ? Color.white.opacity(0.2) : Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
                    .foregroundStyle(highContrast ? .white.opacity(0.8) : .secondary)
            }
        }
        .padding(20)
        .background(highContrast ? Color.black : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(highContrast ? Color.green.opacity(0.6) : Color.clear, lineWidth: 1.5)
        )
    }
}
