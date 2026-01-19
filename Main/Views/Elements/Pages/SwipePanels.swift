import SwiftUI

struct SwipePanels<Content: View, Left: View, Right: View>: View {
    @Binding var showLeft: Bool
    @Binding var showRight: Bool
    let content: Content
    let left: Left?
    let right: Right?

    @GestureState private var drag: CGFloat = 0

    init(
        showLeft: Binding<Bool>,
        showRight: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder left: () -> Left? = { nil },
        @ViewBuilder right: () -> Right? = { nil }
    ) {
        self._showLeft = showLeft
        self._showRight = showRight
        self.content = content()
        self.left = left()
        self.right = right()
    }

    var body: some View {
        GeometryReader { geo in
            let fullW = geo.size.width
            let halfW = fullW / 1.5
            let dx = drag

            ZStack {
                content
                    .disabled(showLeft || showRight)

                if let left = left {
                    left
                        .frame(width: fullW)
                        .frame(maxHeight: .infinity)
                        .offset(x: -halfW + (showLeft ? halfW : 0))
                        .zIndex((showLeft || dx > 0) ? 2 : 1)
                        .opacity(showLeft ? 1 : 0)
                        .animation(.smooth(duration: 0.27), value: showLeft)
                }

                if let right = right {
                    right
                        .frame(width: fullW)
                        .frame(maxHeight: .infinity)
                        .offset(x: halfW - (showRight ? halfW : 0))
                        .zIndex((showRight || dx < 0) ? 2 : 1)
                        .opacity(showRight ? 1 : 0)
                        .animation(.snappy(duration: 0.27), value: showRight)
                }
            }
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .global)
                    .updating($drag) { value, state, _ in
                    }
                    .onEnded { value in
                        handleEnd(value: value, width: fullW)
                    }
            )
        }
    }
    
    private func handleEnd(value: DragGesture.Value, width: CGFloat) {
        let dx = value.translation.width
        let threshold = width * 0.2

        if !showLeft && !showRight {
            if dx > threshold {
                showLeft = true
            } else if dx < -threshold {
                showRight = true
            }
            return
        }

        if showLeft {
            if dx < -threshold {
                closePanels()
            } else {
                showLeft = true
            }
            return
        }

        if showRight {
            if dx > threshold {
                closePanels()
            } else {
                showRight = true
            }
            return
        }
    }

    private func closePanels() {
        withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.9)) {
            showLeft = false
            showRight = false
        }
        onOpenHome()
    }
    
    private func onOpenHome(){
        DiVpnService.checkConnection(){ result in
            DispatchQueue.main.async{
                DiStatus.shared.isEnabled = result
            }
        }
    }
}
