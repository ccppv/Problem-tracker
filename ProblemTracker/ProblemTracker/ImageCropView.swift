import SwiftUI

struct ImageCropView: View {
    var image: NSImage
    @Binding var annotations: [Annotation]
    @Binding var selectedProblem: String
    @State private var startPoint: CGPoint = .zero
    @State private var endPoint: CGPoint = .zero
    @State private var isSelecting = false
    @State private var imageFrame: CGRect = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Отображение изображения
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .background(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                imageFrame = geo.frame(in: .local)
                            }
                        }
                    )
                    .onTapGesture {
                        isSelecting = false
                    }
                    .onAppear {
                        imageFrame = geometry.frame(in: .local)
                    }
                    .overlay(
                        ZStack {
                            // Отображение аннотаций
                            ForEach(annotations, id: \.self) { annotation in
                                Rectangle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: annotation.rect.width, height: annotation.rect.height)
                                    .position(x: annotation.rect.midX, y: annotation.rect.midY)
                                    .border(Color.blue, width: 2)
                            }

                            // Визуализация выделяемой области
                            if isSelecting {
                                let rectWidth = abs(endPoint.x - startPoint.x)
                                let rectHeight = abs(endPoint.y - startPoint.y)
                                Rectangle()
                                    .fill(Color.red.opacity(0.3))
                                    .frame(width: rectWidth, height: rectHeight)
                                    .position(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
                                    .border(Color.red, width: 2)
                            }
                        }
                    )
            }
            .contentShape(Rectangle()) // Ограничивает рамку, в которой происходит взаимодействие
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Проверяем, что начальная точка находится внутри изображения
                        if imageFrame.contains(value.location) {
                            if !isSelecting {
                                startPoint = value.location
                                isSelecting = true
                            }
                            endPoint = value.location
                        }
                    }
                    .onEnded { _ in
                        isSelecting = false
                        guard !selectedProblem.isEmpty else { return }

                        // Создаем аннотацию, если она полностью в пределах изображения
                        let rect = CGRect(x: min(startPoint.x, endPoint.x),
                                          y: min(startPoint.y, endPoint.y),
                                          width: abs(endPoint.x - startPoint.x),
                                          height: abs(endPoint.y - startPoint.y))

                        if imageFrame.contains(rect) {
                            let newAnnotation = Annotation(rect: rect, problem: selectedProblem)
                            annotations.append(newAnnotation)
                        }
                    }
            )
        }
    }
}
