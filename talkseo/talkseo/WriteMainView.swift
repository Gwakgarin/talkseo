//
//  WriteMainView.swift
//  talkseo
//
//  Created by 곽가린 on 11/18/25.
//

import SwiftUI

struct WriteMainView: View {
    let userID: Int
    @State private var books: [RecordBook] = []

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    
                    NavigationLink(destination: SearchBookView(userID:userID)) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Text("책 검색하기")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)


                    // 제목
                    Text("이만큼 읽었어요!")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                        .padding(.leading, 16)
                        .padding(.top, 10)

                    // 완독 책 그리드
                    LazyVGrid(columns: columns, spacing: 28) {

                 
                        ForEach(books) { book in

                            NavigationLink(
                                destination: CompletedBookDetailView(userID:userID,
                                    userBookID: Int(book.user_book_id) ?? 0,
                                    bookTitle: book.title                                )
                            ) {

                                VStack(alignment: .leading, spacing: 8) {

                                    // 표지
                                    AsyncImage(url: URL(string: book.cover_image_url)) { img in
                                        img.resizable()
                                            .aspectRatio(2/3, contentMode: .fill)
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .scaledToFit()
                                    .frame(height: 180)
                                    .clipped()
                                    .cornerRadius(12)

                                    // 제목
                                    Text(book.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .lineLimit(2)
                                        .foregroundColor(.primary)

                                    // 저자
                                    Text(book.author)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .onAppear {
                loadRecordBooks()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    
    func loadRecordBooks() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/get_completed_books.php?user_id=\(userID)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            if let decoded = try? JSONDecoder().decode(RecordResponse.self, from: data) {
                
                DispatchQueue.main.async {
                    books = decoded.books
                }
            }
        }.resume()
    }
}


struct RecordBook: Codable, Identifiable {
    var id: String { user_book_id }
    let user_book_id: String
    let title: String
    let author: String
    let cover_image_url: String
    let total_pages: String
    let current_page: String
}


struct RecordResponse: Codable {
    let books: [RecordBook]
}

#Preview {
    WriteMainView(userID: 1)
}
