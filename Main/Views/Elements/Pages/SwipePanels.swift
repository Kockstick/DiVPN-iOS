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
            let dx = drag

            // Прогресс открытия в [0,1] из фактических оффсетов
            let leftProgress  = left != nil  ? leftOffset(dx, fullW)  / fullW : 0
            let rightProgress = right != nil ? rightOffset(dx, fullW) / fullW : 0
            let progress = max(leftProgress, rightProgress)
            let overlayAlpha = (showLeft || showRight) ? 1 : progress

            ZStack {
                // Контент
                content
                    .disabled(showLeft || showRight)

                // Левая панель
                if let left = left {
                    left
                        .frame(width: fullW)
                        .frame(maxHeight: .infinity)
                        .offset(x: -fullW + leftOffset(dx, fullW))
                        .zIndex((showLeft || dx > 0) ? 2 : 1)
                        .animation(.easeInOut(duration: 0.25), value: showLeft)
                        .animation(.easeInOut(duration: 0.25), value: drag != 0)
                }

                // Правая панель
                if let right = right {
                    right
                        .frame(width: fullW)
                        .frame(maxHeight: .infinity)
                        .offset(x: fullW - rightOffset(dx, fullW))
                        .zIndex((showRight || dx < 0) ? 2 : 1)
                        .animation(.easeInOut(duration: 0.25), value: showRight)
                        .animation(.easeInOut(duration: 0.25), value: drag != 0)
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

    // MARK: - Helpers

    private func leftOffset(_ drag: CGFloat, _ w: CGFloat) -> CGFloat {
        // Если панель открыта, базовое раскрытие = w, плюс "drag" вправо, минус влево
        let base = showLeft ? w : 0
        let total = base + drag
        return min(max(total, 0), w)
    }

    private func rightOffset(_ drag: CGFloat, _ w: CGFloat) -> CGFloat {
        // Аналогично, но в другую сторону: используем модуль
        let base = showRight ? w : 0
        let total = base + abs(min(drag, 0))
        return min(max(total, 0), w)
    }
    
    private func handleEnd(value: DragGesture.Value, width: CGFloat) {
        let dx = value.translation.width
        let threshold = width * 0.2

        if !showLeft && !showRight {
            if dx > threshold { // 150 — мягкий суррогат скорости
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
