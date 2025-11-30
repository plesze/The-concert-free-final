import SwiftUI
import FirebaseFirestore

struct AdminEditConcertView: View {
    // ใช้โครงเดียวกับในลิสต์เพื่อความง่าย
    typealias Concert = AdminConcertListView.Concert

    // ถ้าเป็น nil = เพิ่มใหม่, ถ้าไม่ nil = แก้ไข
    let concert: Concert?
    var onSaved: (Concert) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var subtitle: String = ""
    @State private var date: String = ""
    @State private var time: String = ""
    @State private var location: String = ""
    @State private var imageURL: String = ""
    @State private var detail: String = ""
    @State private var mapURL: String = ""
    @State private var maxSeatsText: String = ""

    @State private var isSaving = false
    @State private var errorMessage: String?

    private let db = Firestore.firestore()

    init(concert: Concert?, onSaved: @escaping (Concert) -> Void) {
        self.concert = concert
        self.onSaved = onSaved
        // ค่าเริ่มต้นจะตั้งใน .onAppear เพื่อให้ @State ถูกเตรียมพร้อม
    }

    var body: some View {
        Form {
            Section("Basic") {
                TextField("Title", text: $title)
                TextField("Subtitle", text: $subtitle)
            }
            Section("When & Where") {
                TextField("Date (เช่น 2025-12-31)", text: $date)
                TextField("Time (เช่น 20:00)", text: $time)
                TextField("Location", text: $location)
                TextField("Map URL", text: $mapURL)
            }
            Section("Media") {
                TextField("Image URL", text: $imageURL)
            }
            Section("Detail") {
                TextEditor(text: $detail)
                    .frame(minHeight: 120)
            }
            Section("Capacity") {
                TextField("Max Seats (เลข)", text: $maxSeatsText)
                    .keyboardType(.numberPad)
            }

            if let errorMessage = errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(concert == nil ? "Add Concert" : "Edit Concert")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    save()
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(isSaving)
            }
        }
        .onAppear {
            if let c = concert {
                title = c.title
                subtitle = c.subtitle
                date = c.date
                time = c.time
                location = c.location
                imageURL = c.imageURL
                detail = c.detail
                mapURL = c.mapURL
                maxSeatsText = String(c.maxSeats)
            }
        }
    }

    private func save() {
        errorMessage = nil

        guard !title.isEmpty,
              !subtitle.isEmpty,
              !date.isEmpty,
              !time.isEmpty,
              !location.isEmpty,
              !imageURL.isEmpty,
              !detail.isEmpty,
              !mapURL.isEmpty,
              let maxSeats = Int(maxSeatsText), maxSeats >= 0
        else {
            errorMessage = "กรุณากรอกข้อมูลให้ครบ และ Max Seats ต้องเป็นตัวเลข"
            return
        }

        isSaving = true

        var payload: [String: Any] = [
            "title": title,
            "subtitle": subtitle,
            "date": date,
            "time": time,
            "location": location,
            "imageURL": imageURL,
            "detail": detail,
            "mapURL": mapURL,
            "maxSeats": maxSeats
        ]

        if let existing = concert {
            // อัปเดต
            db.collection("concerts").document(existing.id).setData(payload, merge: true) { error in
                isSaving = false
                if let error = error {
                    errorMessage = "บันทึกไม่สำเร็จ: \(error.localizedDescription)"
                    return
                }
                let updated = Concert(
                    id: existing.id,
                    title: title,
                    subtitle: subtitle,
                    date: date,
                    time: time,
                    location: location,
                    imageURL: imageURL,
                    detail: detail,
                    mapURL: mapURL,
                    maxSeats: maxSeats
                )
                onSaved(updated)
                dismiss()
            }
        } else {
            // เพิ่มใหม่
            db.collection("concerts").addDocument(data: payload) { error in
                isSaving = false
                if let error = error {
                    errorMessage = "เพิ่มไม่สำเร็จ: \(error.localizedDescription)"
                    return
                }
                // ต้องอ่าน id ล่าสุดกลับมา; ทางง่ายคือ query ล่าสุด หรือใช้ document() แล้ว setData
                let newDoc = db.collection("concerts").document()
                // ใช้วิธีสร้าง id เองเพื่อให้รู้ id แน่นอน แล้วค่อย setData
                isSaving = true
                newDoc.setData(payload) { err in
                    isSaving = false
                    if let err = err {
                        errorMessage = "เพิ่มไม่สำเร็จ: \(err.localizedDescription)"
                        return
                    }
                    let created = Concert(
                        id: newDoc.documentID,
                        title: title,
                        subtitle: subtitle,
                        date: date,
                        time: time,
                        location: location,
                        imageURL: imageURL,
                        detail: detail,
                        mapURL: mapURL,
                        maxSeats: maxSeats
                    )
                    onSaved(created)
                    dismiss()
                }
            }
        }
    }
}
