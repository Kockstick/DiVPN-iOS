import SwiftUI

struct DrawButton: View {
    let title: LocalizedStringKey
    let bgColor: Color
    let textColor: Color
    let isLoading: Bool
    let action: () -> Void

    private let height: CGFloat = 60
    private let shadowColor: Color = .black.opacity(0.15)
    private let borderColor: Color = Color("Border")
    private let backgroundImage = Image("ButtonBackground")
    private let borderImage = Image("ButtonBorder")

    var body: some View {
        Button {
            guard !isLoading else { return }
            action()
        } label: {
            ZStack {
                // ФОН
                backgroundImage
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .foregroundStyle(bgColor)
                    .shadow(color: shadowColor, radius: 5, x: 0, y: 5)
                    .allowsHitTesting(false)
                    .padding(.horizontal, 2)

                // КОНТЕНТ
                Group {
                    if isLoading {
                        CircleLoader(color: textColor)
                            .frame(maxWidth: .infinity, maxHeight: height - 5)
                            .accessibilityLabel(Text("Loading"))
                    } else {
                        Text(title)
                            .font(.body.bold())
                            .foregroundStyle(textColor)
                            .frame(maxWidth: .infinity, maxHeight: height - 5)
                            .accessibilityLabel(Text(title))
                    }
                }
                .allowsHitTesting(false)

                borderImage
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: height + 2)
                    .foregroundStyle(borderColor)
                    .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        // если нужно увеличить «хит-слоп», а не визуал:
        //.padding(.vertical, 4).contentShape(Rectangle())
    }
}
