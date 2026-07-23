//
//  DetailBookView.swift
//  talkseo
//
//  Created by 곽가린 on 11/7/25.
//

import SwiftUI

struct DetailBookView: View {
    @State var session: BookSession
    @State private var showMenu = false
    @State private var showDeleteAlert = false
    @State private var showEdit = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {

            // 상단
            HStack {
                Spacer()
                Text(formatDate(session.session_date))
                    .font(.headline)
                    .padding(.leading, 14)
                Spacer()

                Button {
                    showMenu.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                }
                .padding(.trailing)
                .confirmationDialog("옵션", isPresented: $showMenu) {
                    Button("수정하기") {
                        showEdit = true
                    }
                    Button("삭제하기", role: .destructive) {
                        showDeleteAlert = true
                    }
                }
            }
            .padding(.top, 10)

            // 책 정보
            VStack(spacing: 10) {
                Text(session.title)
                    .font(.title2)
                    .fontWeight(.bold)

                if let url = URL(string: session.cover_image_url),
                   !url.absoluteString.isEmpty {
                    AsyncImage(url: url) { img in
                        img.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .scaledToFit()
                    .frame(width: 180, height: 260)
                    .cornerRadius(12)
                }
            }

            // 기록 정보
            VStack(spacing: 16) {
                RecordItemView(
                    title: "집중 시간",
                    value: formatTime(totalSeconds: session.reading_time)
                )

                RecordItemView(
                    title: "페이지",
                    value: "\(session.end_page)/\(session.total_pages)"
                )
            }
            .padding()

            Spacer()
        }
        // 수정 sheet
        .sheet(isPresented: $showEdit) {
            EditSessionView(session: session) { newSec, newPage in
                session.reading_time = "\(newSec)"
                session.end_page = "\(newPage)"
            }
        }
        // 삭제 alert
        .alert("정말 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                deleteSession()
            }
            Button("취소", role: .cancel) {}
        }
    }

    func deleteSession() {
        guard let url = URL(
            string: "http://124.56.5.77/talkseo/ip02/delete_session.php?session_id=\(session.session_id)"
        ) else { return }

        URLSession.shared.dataTask(with: url) { _, _, _ in
            DispatchQueue.main.async {
                dismiss()
            }
        }.resume()
    }
}



struct RecordItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(radius: 2)
    }
}



func formatDate(_ str: String) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    if let date = formatter.date(from: str) {
        formatter.dateFormat = "yyyy.MM.dd(E) HH:mm"
        return formatter.string(from: date)
    }
    return str
}

func formatTime(totalSeconds: String) -> String {
    guard let sec = Int(totalSeconds) else { return "00:00:00" }
    let h = sec / 3600
    let m = (sec % 3600) / 60
    let s = sec % 60
    return String(format: "%02d:%02d:%02d", h, m, s)
}



#Preview {
    DetailBookView(session: BookSession(
        session_id: 1,
        title: "사서함 110호의 우편물",
        cover_image_url: "https://image.yes24.com/goods/110832417/XL",
        total_pages: "512",
        current_page: "45",
        start_date: "2025-11-03 17:01:16",
        end_date: "",
        total_reading_time: "1285",
        session_date: "2025-11-07 18:16:19",
        reading_time: "1285",
        start_page: "35",
        end_page: "45"
    ))
}
