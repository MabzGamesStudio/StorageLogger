import SwiftUI

struct EntryView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: EntryViewModel

    @State private var imageChanged = false
    @State private var name = ""
    @State private var price = ""
    @State private var quantity = ""
    @State private var description = ""
    @State private var notes = ""
    @State private var tags = ""
    @State private var selectedDate = Date()
    @State private var showDiscardAlert = false
    @State private var adViewModel = InterstitialViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    @Binding var isAddingEntry: Bool
    
    init(dataStore: DataStore, entry: Entry, newEntry: Bool, isAddingEntry: Binding<Bool>) {
        self._isAddingEntry = isAddingEntry
        self._viewModel = StateObject(wrappedValue: EntryViewModel(entry: entry, dataStore: dataStore, isNewEntry: newEntry, adViewModel: InterstitialViewModel()))
        _name = State(initialValue: entry.name ?? "")
        _price = State(initialValue: entry.price.map { String(format: "%.2f", $0) } ?? "")
        _quantity = State(initialValue: entry.quantity.map { String($0) } ?? "")
        _description = State(initialValue: entry.description ?? "")
        _notes = State(initialValue: entry.notes ?? "")
        _tags = State(initialValue: entry.tags ?? "")
        _selectedDate = State(initialValue: entry.buyDate ?? Date())
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
    
    private var imagePickerView: some View {
        VStack {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .onTapGesture { viewModel.showPhotoOptions = true }

                Button("Change Image") { viewModel.showPhotoOptions = true }
                    .padding()
            } else {
                Text("Select an Image")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .onTapGesture { viewModel.showPhotoOptions = true }
            }
        }
        .actionSheet(isPresented: $viewModel.showPhotoOptions) { photoOptionsActionSheet }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(image: $viewModel.selectedImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $viewModel.showCamera) {
            ImagePicker(image: $viewModel.selectedImage, sourceType: .camera)
        }
        .onChange(of: viewModel.selectedImage) {
            imageChanged = true
            viewModel.checkForChanges(
                imageChanged: imageChanged,
                name: name,
                price: price,
                quantity: quantity,
                description: description,
                notes: notes,
                tags: tags,
                selectedDate: selectedDate
            )
        }
    }

    private var inputFieldsView: some View {
        VStack {
            ForEach(inputFields, id: \.0) { field in
                TextField(field.0, text: field.1)
                    .keyboardType(field.2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .focused($isTextFieldFocused)
                    .onChange(of: field.1.wrappedValue) {
                        viewModel.checkForChanges(
                            imageChanged: imageChanged,
                            name: name,
                            price: price,
                            quantity: quantity,
                            description: description,
                            notes: notes,
                            tags: tags,
                            selectedDate: selectedDate
                        )
                    }
            }
            DatePicker("Buy Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding()
                .focused($isTextFieldFocused)
        }
    }

    private var saveButton: some View {
        Button(action: {
            viewModel.uploadEntry(
                name: name,
                price: price,
                quantity: quantity,
                description: description,
                notes: notes,
                tags: tags,
                selectedDate: selectedDate,
                presentationMode: presentationMode
            )
        }) {
            Text(viewModel.isNewEntry ? "Add Entry" : "Edit Entry")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(viewModel.isUploading)
    }

    private var discardAlert: Alert {
        Alert(
            title: Text("Discard Changes?"),
            primaryButton: .destructive(Text("Discard")) {
                isAddingEntry = false
            },
            secondaryButton: .cancel()
        )
    }

    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { isTextFieldFocused = false }
        }
    }

    private var photoOptionsActionSheet: ActionSheet {
        ActionSheet(
            title: Text("Choose Image Source"),
            buttons: [
                .default(Text("Take a Photo")) {
                    viewModel.sourceType = .camera
                    viewModel.showCamera = true
                },
                .default(Text("Choose from Photos")) {
                    viewModel.sourceType = .photoLibrary
                    viewModel.showImagePicker = true
                },
                .cancel()
            ]
        )
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    imagePickerView
                    inputFieldsView
                    saveButton
                }
                .padding()
                .navigationTitle(viewModel.isNewEntry ? "New Entry" : "Update Entry")
                .toolbar(content: { keyboardToolbar })
                .alert(isPresented: $showDiscardAlert) { discardAlert }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            if viewModel.hasChanges {
                showDiscardAlert = true
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }) {
            Image(systemName: "chevron.left")
            Text("Entries")
        })
    }

}
