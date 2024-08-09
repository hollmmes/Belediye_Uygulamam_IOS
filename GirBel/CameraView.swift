import SwiftUI
import FirebaseDatabase
import FirebaseStorage

struct CameraView: View {
    @State private var name = ""
    @State private var idNumber = ""
    @State private var address = ""
    @State private var contactNumber = ""
    @State private var issueDescription = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isKvkkAccepted = false

    private let databaseRef = Database.database().reference().child("form_submissions")
    private let storageRef = Storage.storage().reference().child("images")

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("İsim Soyisim", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("TC Kimlik No", text: $idNumber)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Adres", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("İletişim Numarası", text: $contactNumber)
                    .keyboardType(.phonePad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Sorun", text: $issueDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Toggle("KVKK Onayı", isOn: $isKvkkAccepted)
                    .padding(.horizontal)

                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                }

                Button("Galeriden Fotoğraf Seç") {
                    isImagePickerPresented = true
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)

                Button("Gönder") {
                    sendData()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .navigationTitle("Çek Gönder")
            .padding()
        }
    }

    private func sendData() {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd_MM_yyyy"
        let dateString = formatter.string(from: currentDate)
        let key = "\(name.replacingOccurrences(of: " ", with: "_"))_\(dateString)"

        var formData: [String: Any] = [
            "name": name,
            "tc_number": idNumber,
            "address": address,
            "contact": contactNumber,
            "issue": issueDescription,
            "kvkk_accepted": isKvkkAccepted
        ]

        if let selectedImage = selectedImage {
            uploadImage(key: key, formData: formData)
        } else {
            saveToDatabase(key: key, formData: formData)
        }
    }

    private func uploadImage(key: String, formData: [String: Any]) {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }

        let imageRef = storageRef.child("\(key).jpg")
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard error == nil else {
                // Handle error
                return
            }
            imageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    // Handle error
                    return
                }
                
                // Create a new dictionary by adding the image URL to the existing formData
                var updatedFormData = formData
                updatedFormData["image_url"] = downloadURL.absoluteString
                
                // Save to database
                self.saveToDatabase(key: key, formData: updatedFormData)
            }
        }
    }

    private func saveToDatabase(key: String, formData: [String: Any]) {
        databaseRef.child(key).setValue(formData) { error, _ in
            if error == nil {
                // Handle success (e.g., show a success message)
            } else {
                // Handle failure
            }
        }
    }
}


import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}

