//
//  SearchBook.swift
//  talkseo3
//
//  Created by mac11 on 11/3/25.
//

import SwiftUI

struct Book: Codable{
    var book_id : String?
    var book_title : String?
    var book_image : String?
    var book_author : String?
    var book_publisher : String?
}
    
struct SearchBookItem: View{
        
        @State var bookData : Book
        var body: some View {
            HStack {
                   Text(bookData.book_image ?? "")
                   Text(bookData.book_title ?? "")
                   Text(bookData.book_author ?? "")
                   Text(bookData.book_publisher ?? "")
            }
        }
    
}


struct SearchBookView: View {
    let userID: Int
    @State private var books: Books = Books(books: [])
    @State private var searchQuery: String = ""
    
    var body: some View {
        NavigationView { // <-- NavigationView 추가
            VStack {
                // 검색창
                TextField("책을 입력해주세요.", text: $searchQuery)
                    .padding(10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onChange(of: searchQuery) { newValue in
                        fetchBooks(search: newValue)
                    }
                
                // 책 리스트
                List(books.books, id: \.book_id) { book in
                    if let id = book.book_id {
                        NavigationLink(destination: SearchDetailView(userID: userID, book_id: id)) { // 상세페이지로 이동
                            HStack {
                                if let img = book.book_image {
                                    Text(img) // 실제 앱에서는 AsyncImage 등으로 바꾸세요
                                }
                                VStack(alignment: .leading) {
                                    Text(book.book_title ?? "")
                                    Text(book.book_author ?? "")
                                    Text(book.book_publisher ?? "")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("책 검색") // 네비게이션 바 타이틀
            .onAppear { fetchBooks(search: "") }
        }
    }
    
    // MARK: - 책 리스트 불러오기
    func fetchBooks(search: String) {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/book.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "search=\(search)"
        request.httpBody = body.data(using: .utf8)	
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                if let jsonBooks = try? JSONDecoder().decode(Books.self, from: data) {
                    DispatchQueue.main.async {
                        self.books = jsonBooks
                    }
                } else {
                    print(String(decoding: data, as: UTF8.self))
                }
            } else if let error = error {
                print(error)
            }
        }.resume()
    }
}



struct Books : Codable{
    var books:[Book]
}


#Preview {
    SearchBookView(userID:1)
}
