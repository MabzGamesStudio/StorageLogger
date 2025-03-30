import SwiftUI
import PhotosUI
import GoogleMobileAds

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
    @Binding var isAddingEntry: Bool
    @State private var showDiscardAlert = false
    @State private var hasChanges = false
    @State private var selectedImageChanged: Bool = false
    @StateObject private var adViewModel = InterstitialViewModel()
    
    init(dataStore: DataStore, entry: Entry, newEntry: Bool, isAddingEntry: Binding<Bool>) {
        self.dataStore = dataStore
        self.entry = entry
        self.newEntry = newEntry
        self._isAddingEntry = isAddingEntry
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
    
    private func checkForChanges() {
        hasChanges =
            entry.name != name
            || selectedImageChanged
            || entry.price != Double(price)
            || entry.quantity != Int(quantity)
            || entry.description != description
            || entry.notes != notes
            || entry.tags != tags
            || entry.buyDate != selectedDate
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
                    .onChange(of: selectedImage) {
                        selectedImageChanged = true
                        checkForChanges()
                    }
                    // TODO: Fix image change
                    
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                        .onChange(of: name) { checkForChanges() }
                    
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                        .onChange(of: price) { checkForChanges() }
                    
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                        .onChange(of: quantity) { checkForChanges() }
                    
                    TextField("Description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                        .onChange(of: description) { checkForChanges() }
                    
                    TextField("Notes", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                        .onChange(of: notes) { checkForChanges() }
                    
                    TextField("Tags", text: $tags)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .focused($isTextFieldFocused)
                        .onChange(of: tags) { checkForChanges() }
                    
                    DatePicker("Buy Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .focused($isTextFieldFocused)
                        .onChange(of: selectedDate) { checkForChanges() }
                    Button(action: uploadEntry) {
                        Text(newEntry ? (isUploading ? "Adding Entry..." : "Add Entry") : (isUploading ? "Editing Entry..." : "Edit Entry"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .onAppear {
                        Task {
                            await adViewModel.loadAd()
                        }
                    }
                    .padding()
                    .disabled(isUploading)
                }
                .padding()
                .navigationTitle(newEntry ? "New Entry" : "Update Entry")
                .onTapGesture {
                    isTextFieldFocused = false
                }
                .toolbar(content: {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isTextFieldFocused = false
                        }
                    }
                })
                .alert(isPresented: $showDiscardAlert) {
                    Alert(
                        title: Text("Discard Changes?"),
                        primaryButton: .destructive(Text("Discard")) {
                            isAddingEntry = false
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            if hasChanges {
                showDiscardAlert = true
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }) {
            Image(systemName: "chevron.left")
            Text("Entries")
        })
        .alert(isPresented: $showDiscardAlert) {
            Alert(
                title: Text("Discard Changes?"),
                message: Text("Are you sure you want to leave without saving?"),
                primaryButton: .destructive(Text("Discard")) {
                    self.presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }

    func uploadEntry() {
        let imageFilename = selectedImage.flatMap { saveImageToDocumentsDirectory(image: $0, maxFileSizeKB: 150) }
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
        if let encodedData = try? JSONEncoder().encode(dataStore.entries) {
            UserDefaults.standard.set(encodedData, forKey: "entries")
        }
        
        if dataStore.counterForAd == 5 {
            dataStore.resetCounterForAd()
            adViewModel.showAd()
        } else {
            dataStore.incrementCounterForAd()
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    func loadImageFromDocumentsDirectory(filename: String) -> UIImage? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageDataFolderURL = documentsURL.appendingPathComponent("ImageData")
        let fileURL = imageDataFolderURL.appendingPathComponent(filename)
        
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func saveImageToDocumentsDirectory(image: UIImage, maxFileSizeKB: Int) -> String? {
        let maxFileSize = maxFileSizeKB * 1024
        var compression: CGFloat = 0.0
        var imageData: Data? = image.jpegData(compressionQuality: compression)
        
        while let data = imageData, data.count > maxFileSize, compression > 0.01 {
            compression -= 0.01
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        guard let finalData = imageData else { return nil }
        
        let filename = UUID().uuidString + ".jpg"
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageDataFolderURL = documentsURL.appendingPathComponent("ImageData")
        if !FileManager.default.fileExists(atPath: imageDataFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: imageDataFolderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory: \(error)")
            }
        }
        let fileURL = imageDataFolderURL.appendingPathComponent(filename)
        
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
