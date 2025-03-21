import SwiftUI
import PhotosUI

struct EntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var id: String? = ""
    @State private var name = ""
    @State private var price = ""
    @State private var quantity = ""
    @State private var description = ""
    @State private var notes = ""
    @State private var tags = ""
    @State private var selectedDate = Date()
    @State private var isUploading = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var showPhotoOptions = false
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State var newEntry: Bool
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @ObservedObject var dataStore = DataStore()
    @State var entry: Entry
    
    init(dataStore: DataStore, entry: Entry, newEntry: Bool) {
        self.dataStore = dataStore
        _id = State(initialValue: entry.id)
        _entry = State(initialValue: entry)
        _name = State(initialValue: entry.name ?? "")
        _price = State(initialValue: entry.price.map { String(format: "%.2f", $0) } ?? "")
        _quantity = State(initialValue: entry.quantity.map { String($0) } ?? "")
        _description = State(initialValue: entry.description ?? "")
        _notes = State(initialValue: entry.notes ?? "")
        _tags = State(initialValue: entry.tags ?? "")
        _selectedDate = State(initialValue: entry.buyDate ?? Date())
        _newEntry = State(initialValue: newEntry)
        _selectedImage = State(initialValue: entry.imageFilename != nil && !newEntry ? loadImageFromDocumentsDirectory(filename: entry.imageFilename!) : nil)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .onTapGesture {
                                    showPhotoOptions = true // Allow user to reselect
                                }
                            
                            Button("Change Image") {
                                showPhotoOptions = true
                            }
                            .padding()
                        } else {
                            Text("Select an Image")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .onTapGesture {
                                    showPhotoOptions = true // Initial selection
                                }
                        }
                    }
                    .actionSheet(isPresented: $showPhotoOptions) {
                        ActionSheet(
                            title: Text("Choose Image Source"),
                            buttons: [
                                .default(Text("Take a Photo")) {
                                    sourceType = .camera
                                    showCamera = true
                                },
                                .default(Text("Choose from Photos")) {
                                    sourceType = .photoLibrary
                                    showImagePicker = true
                                },
                                .cancel()
                            ]
                        )
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
                    }
                    .fullScreenCover(isPresented: $showCamera) {
                        ImagePicker(image: $selectedImage, sourceType: .camera)
                    }
                    
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                    
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                    
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                    
                    TextField("Description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                    
                    TextField("Notes", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                    
                    TextField("Tags", text: $tags)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                    
                    DatePicker("Buy Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .focused($isTextFieldFocused)
                    Button(action: uploadEntry) {
                        Text(newEntry ? (isUploading ? "Adding Entry..." : "Add Entry") : (isUploading ? "Editing Entry..." : "Edit Entry"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(isUploading)
                }
                .padding()
                .navigationTitle("New Entry")
                .onTapGesture {
                    isTextFieldFocused = false
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isTextFieldFocused = false
                        }
                    }
                }
            }
        }
    }

    func uploadEntry() {
        let imageFilename = selectedImage.flatMap { saveImageToDocumentsDirectory(image: $0, maxFileSizeKB: 500) }
        let price = Double(price).flatMap { $0.isNaN ? nil : $0 }
        let quantity = Int(quantity) ?? nil
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : name
        let description = description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description
        let notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
        let tags = tags.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tags
        let editedEntry = Entry(
            id: entry.id,
            imageFilename: imageFilename,
            name: name,
            price: price,
            quantity: quantity,
            description: description,
            notes: notes,
            tags: tags,
            buyDate: selectedDate
        )
        if newEntry {
            dataStore.addEntry(editedEntry)
        } else {
            if let index = dataStore.entries.firstIndex(where: { $0.id == editedEntry.id }) {
                dataStore.entries[index] = editedEntry
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    func loadImageFromDocumentsDirectory(filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func saveImageToDocumentsDirectory(image: UIImage, maxFileSizeKB: Int) -> String? {
        let maxFileSize = maxFileSizeKB * 1024
        var compression: CGFloat = 1.0
        var imageData: Data? = image.jpegData(compressionQuality: compression)
        
        while let data = imageData, data.count > maxFileSize, compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        guard let finalData = imageData else { return nil }
        
        let filename = UUID().uuidString + ".jpg"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        do {
            try finalData.write(to: fileURL)
            return filename
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}
