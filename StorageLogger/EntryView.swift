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
    @State var isNewEntry: Bool
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
        self.isNewEntry = newEntry
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
        _isNewEntry = State(initialValue: newEntry)
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
    
    private var inputFields: [(title: String, binding: Binding<String>, keyboardType: UIKeyboardType)] {
        [
            ("Name", $name, .default),
            ("Price", $price, .decimalPad),
            ("Quantity", $quantity, .numberPad),
            ("Description", $description, .default),
            ("Notes", $notes, .default),
            ("Tags", $tags, .default)
        ]
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
                    
                    ForEach(inputFields, id: \.title) { field in
                        TextField(field.title, text: field.binding)
                            .keyboardType(field.keyboardType)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .focused($isTextFieldFocused)
                            .onChange(of: field.binding.wrappedValue) {
                                checkForChanges()
                            }
                    }
                    
                    DatePicker("Buy Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                        .focused($isTextFieldFocused)
                        .onChange(of: selectedDate) {
                            checkForChanges()
                        }
                    
                    Button(action: uploadEntry) {
                        Text(isNewEntry ? (isUploading ? "Adding Entry..." : "Add Entry") : (isUploading ? "Editing Entry..." : "Edit Entry"))
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
                .navigationTitle(isNewEntry ? "New Entry" : "Update Entry")
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
        isUploading = true
        let newEntry = Entry(
            id: entry.id,
            imageFilename: nil,
            name: name,
            price: Double(price),
            quantity: Int(quantity),
            description: description,
            notes: notes,
            tags: tags,
            buyDate: selectedDate
        )
        if isNewEntry {
            dataStore.addEntry(entry: newEntry, image: selectedImage)
        } else {
            if let index = dataStore.entries.firstIndex(where: { $0.id == newEntry.id }) {
                dataStore.updateEntry(index: index, newEntry: newEntry, image: selectedImage)
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
}
