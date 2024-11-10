import SwiftUI
struct AddProblemView: View {
    @State private var image: NSImage? = nil
    @State private var annotations: [Annotation] = []
    @State private var selectedProblem: String = ""
    let problems = ["Проблема 1", "Проблема 2", "Проблема 3", "Проблема 4", "Проблема 5"]

    var body: some View {
        VStack {
            Text("Добавить проблему")
                .font(.largeTitle)
                .padding()

            // Внутри AddProblemView
            if let image = image {
                ImageCropView(image: image, annotations: $annotations, selectedProblem: $selectedProblem)
                    .frame(height: 300)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(Text("Перетащите сюда изображение"))
                    .border(Color.black, width: 1)
                    .padding()
            }
            Picker("Выберите проблему", selection: $selectedProblem) {
                ForEach(problems, id: \.self) { problem in
                    Text(problem)
                }
            }
            .padding()

            // Кнопка загрузки изображения
            Button("Загрузить изображение") {
                openImage()
            }
            .padding()

            // Кнопка сохранения изображения и аннотаций
            Button("Сохранить изображение и аннотации") {
                if let image = image, !selectedProblem.isEmpty {
                    saveImageWithAnnotations(image: image)
                } else {
                    print("Пожалуйста, выберите проблему перед сохранением.")
                }
            }
            .padding()
        }
    }
    
    // Функция открытия изображения через NSOpenPanel
    private func openImage() {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["png", "jpg", "jpeg"]
        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                if let nsImage = NSImage(contentsOf: url) {
                    self.image = nsImage
                    self.annotations = []
                    print("Изображение успешно загружено: \(url.path)")
                } else {
                    print("Не удалось загрузить изображение из URL.")
                }
            }
        }
    }

    // Функция сохранения изображения и аннотаций с использованием выбранной проблемы
    private func saveImageWithAnnotations(image: NSImage) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["png"]
        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                do {
                    if let tiffData = image.tiffRepresentation,
                       let bitmap = NSBitmapImageRep(data: tiffData),
                       let pngData = bitmap.representation(using: .png, properties: [:]) {
                        try pngData.write(to: url)
                        
                        // Сохранение аннотаций с проблемой
                        saveAnnotationsToMetadata(annotations: annotations, imageURL: url)
                        print("Изображение и аннотации успешно сохранены.")
                    }
                } catch {
                    print("Ошибка сохранения изображения: \(error.localizedDescription)")
                }
            }
        }
    }

    private func saveAnnotationsToMetadata(annotations: [Annotation], imageURL: URL) {
        let metadataFileURL = imageURL.deletingPathExtension().appendingPathExtension("json")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(annotations)
            try data.write(to: metadataFileURL)
            print("Аннотации успешно сохранены в файл: \(metadataFileURL.path)")
        } catch {
            print("Ошибка сохранения аннотаций: \(error.localizedDescription)")
        }
    }
}
