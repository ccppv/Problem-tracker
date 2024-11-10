import SwiftUI

struct ProfileView: View {
    @State private var flags: [String] = []
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            Text("Профиль")
                .font(.largeTitle)
                .padding()

            // Кнопка для загрузки файла
            Button("Загрузить файл .vmem") {
                loadVmemFile()
            }
            .padding()

            // Отображаем флаги
            if let errorMessage = errorMessage {
                Text("Ошибка: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else if flags.isEmpty {
                Text("Флаги не загружены.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(flags, id: \.self) { flag in
                    Text(flag)
                }
                .frame(height: 300)
            }
        }
        .padding()
    }

    private func loadVmemFile() {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["vmem"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false

        if openPanel.runModal() == .OK, let url = openPanel.url {
            do {
                let data = try Data(contentsOf: url)
                
                // Пример разбора бинарных данных
                // Если знаете, как данные структурированы, разбирайте их здесь
                parseBinaryData(data)
            } catch {
                errorMessage = "Ошибка загрузки файла: \(error.localizedDescription)"
            }
        }
    }

    private func parseBinaryData(_ data: Data) {
        // Пример разбора данных
        // Предполагается, что данные представляют собой массив флагов
        let flagsArray = data.split(separator: 0) // Это просто пример
        flags = flagsArray.map { String(decoding: $0, as: UTF8.self) }
        errorMessage = nil
    }

    private func parseFlags(from content: String) {
        // Здесь можно добавить свою логику для разбора строк и извлечения флагов
        // Например, если флаги разделены запятыми:
        flags = content.components(separatedBy: "\n").filter { !$0.isEmpty }
        errorMessage = nil // Сбросим сообщение об ошибке, если загрузка прошла успешно
    }
}

