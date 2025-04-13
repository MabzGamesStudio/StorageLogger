import SwiftUI

/// A view for adding or editing an `Entry`, including image selection and entry input fields.
struct EntryView: View {
    
    /// A view for adding or editing an `Entry`, including image selection and various input fields.
    @Environment(\.presentationMode) var presentationMode
    
    /// ViewModel for managing entry data and state.
    @StateObject private var viewModel: EntryViewModel

    /// Whether the selected entry image has changed
    @State private var imageChanged = false
    
    /// Each of the entry input data fields
    @State private var name = ""
    @State private var price = ""
    @State private var quantity = ""
    @State private var description = ""
    @State private var notes = ""
    @State private var tags = ""
    @State private var selectedDate = Date()
    
    /// Whether to show the discard entry data alert
    @State private var showDiscardAlert = false
    
    /// The ad to possibly load following an entry addition or update
    @State private var adViewModel = InterstitialViewModel()
    
    /// Whether the text field of an entry is focused
    @FocusState private var isTextFieldFocused: Bool
    
    /// Controls presentation of this view.
    @Binding var isAddingEntry: Bool
    
    /// Initializes the EntryView with entry data, store, and edit state.
    /// - Parameters:
    ///   - dataStore: The shared data store.
    ///   - entry: The entry to display or edit.
    ///   - newEntry: Whether this is a new entry or updating an existing one.
    ///   - isAddingEntry: Binding to the flag tracking this view’s presentation.
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
    
    /// Array of input field metadata for rendering input rows.
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
    
    /// A view to display and pick an image for the entry.
    private var imagePickerView: some View {
        VStack {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .onTapGesture { viewModel.showPhotoOptions = true }
                Button("Change Image") { viewModel.showPhotoOptions = true }
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                Text("Select an Image")
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .onTapGesture { viewModel.showPhotoOptions = true }
            }
        }
        
        /// Presents an action sheet with options to select an image source (camera or photo library)
        .actionSheet(isPresented: $viewModel.showPhotoOptions) { photoOptionsActionSheet }
        
        /// Presents a modal sheet for selecting an image from the photo library
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(image: $viewModel.selectedImage, sourceType: .photoLibrary)
        }
        
        /// Presents a full-screen camera view to capture a new photo
        .fullScreenCover(isPresented: $viewModel.showCamera) {
            ImagePicker(image: $viewModel.selectedImage, sourceType: .camera)
        }
        
        /// Observes changes to the selected image and updates the view model state accordingly
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

    /// A view for all the input fields related to the entry.
    private var inputFieldsView: some View {
        VStack {
            
            // Iteration through text-based input fields
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
            
            // Buy date input field
            DatePicker("Buy Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding()
                .focused($isTextFieldFocused)
        }
    }

    /// A button that triggers save or update entry, depending on state.
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

    /// An alert shown when attempting to discard changes.
    private var discardAlert: Alert {
        Alert(
            title: Text("Discard Changes?"),
            primaryButton: .destructive(Text("Discard")) {
                isAddingEntry = false
            },
            secondaryButton: .cancel()
        )
    }

    /// Toolbar displayed with keyboard and "Done" button to allow dismissal.
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { isTextFieldFocused = false }
        }
    }

    /// Action sheet with image selection options.
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

    /// The main UI body of the view.
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
        
        // When navigating back to entries list view, alert user if changes will be discarded
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
