import SwiftUI

struct MetadataView: View {
    @State private var selectedImage: NSImage?
    @State private var metadata: [Annotation] = []
    @State private var metadataError: String? = nil

    var body: some View {
        VStack {
            // Скрываем область для загрузки, если изображение загружено
            if selectedImage == nil {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(Text("Перетащите сюда фотографию или выберите JSON").foregroundColor(.secondary))
                    .border(Color.black, width: 1)
                    .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                        handleFileDrop(providers: providers)
                        return true
                    }
                    .padding(.bottom)
            }
            
            // Отображаем изображение, если оно загружено
            if let image = selectedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .padding(.bottom)
            }
            
            // Отображаем сообщение об ошибке, если метаданные не удалось загрузить
            if let error = metadataError {
                Text("Ошибка загрузки метаданных: \(error)")
                    .foregroundColor(.red)
            }
            
            // Если метаданные найдены, отображаем их в виде списка
            if !metadata.isEmpty {
                Text("Метаданные:")
                    .font(.headline)
                    .padding(.top)
                
                List(metadata, id: \.problem) { annotation in
                    VStack(alignment: .leading) {
                        Text("Проблема: \(annotation.problem)")
                            .font(.subheadline)
                        Text("Область: \(annotation.rect)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .frame(height: 200)
            } else if metadataError == nil && selectedImage != nil {
                Text("Метаданные не найдены")
                    .foregroundColor(.gray)
                    .padding()
            }

            // Кнопка для выбора JSON файла с метаданными
            Button("Выбрать JSON с метаданными") {
                selectAndLoadMetadata()
            }
            .padding(.top)
        }
        .padding()
    }
    
    private func handleFileDrop(providers: [NSItemProvider]) {
        if let item = providers.first {
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (data, error) in
                DispatchQueue.main.async {
                    if let urlData = data as? Data,
                       let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                        if url.pathExtension.lowercased() == "json" {
                            loadMetadata(from: url)
                        } else if let image = NSImage(contentsOf: url) {
                            self.selectedImage = image
                            let metadataUrl = url.deletingPathExtension().appendingPathExtension("json")
                            loadMetadata(from: metadataUrl)
                        }
                    }
                }
            }
        }
    }

    private func loadMetadata(from metadataUrl: URL) {
        do {
            let data = try Data(contentsOf: metadataUrl)
            let decoder = JSONDecoder()
            let annotations = try decoder.decode([Annotation].self, from: data)
            self.metadata = annotations
            self.metadataError = nil
        } catch {
            print("Ошибка загрузки метаданных: \(error.localizedDescription)")
            self.metadata = []
            self.metadataError = "Не удалось загрузить метаданные. Проверьте формат файла."
        }
    }

    private func selectAndLoadMetadata() {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["json"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            loadMetadata(from: url)
        }
    }
}
