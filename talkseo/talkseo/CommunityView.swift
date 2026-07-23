//
//  CommunityView.swift
//  talkseo
//
//  Created by mac28 on 10/27/25.
//

import SwiftUI

struct Post: Codable {
    var user_id:String?
    var nickname:String?
    var profile_image_url:String?
    var content:String?
    var update_date:String?
    var post_id:Int?
    var title:String?
    var insert_date:String?
    var like_count:Int?
    var comment_count:Int?
}

struct PostItem:View {
    var postData : Post
    var body: some View {
        NavigationLink {
            ComuDetailView(post_id: postData.post_id!)
        } label: {
            VStack(alignment: .leading) {
                Text(postData.title ?? "")
                    .fontWeight(.bold)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(postData.content ?? "")
                    .font(.body)
                    .lineLimit(2) // 내용 두 줄만 표시
                HStack(spacing: 12){
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                        Text(String(postData.like_count ?? 0))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                        Text(String(postData.comment_count ?? 0))
                    }
                }.padding(.vertical, 1)
            }.padding(.vertical, 8)
        }
    }
}

struct Posts: Codable{
    var COMMUNITY_POST:[Post]
}

struct CommunityView: View {
    @State var COMMUNITY_POST: Posts = Posts(COMMUNITY_POST: [Post]())

    var body: some View {
        NavigationView {
            VStack {
                Text("커뮤니티")
                    .fontWeight(.bold)
                    .font(.system(size: 28))
                
                List(COMMUNITY_POST.COMMUNITY_POST, id:\.post_id) { contents in
                    PostItem(postData: contents)
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal, 8)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: ComuWriteView(onPostCompleted: {
                            fetchPosts()
                        })
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 16))
                            Text("글쓰기")
                                .font(.system(size: 15))
                                .bold()
                        }
                    }
                    .foregroundColor(Color(red: 0.41, green: 0.70, blue: 0.39))
                }
            }
            .onAppear {
                fetchPosts()
            }
        }
    }
    
    private func fetchPosts() {
        guard let url = URL(string: "http://124.56.5.77/talkseo/ip02/comu.php") else {
            print("url error")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "".data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("네트워크 에러:", error)
                return
            }
            
            guard let data = data else {
                print("데이터 없음")
                return
            }
            
            let str2 = String(decoding: data, as: UTF8.self)
            print("서버 JSON:", str2)
            
            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(Posts.self, from: data)

                    let sortedPosts = jsonData.COMMUNITY_POST.sorted {
                        ($0.post_id ?? 0) > ($1.post_id ?? 0)
                    }

                    self.COMMUNITY_POST = Posts(COMMUNITY_POST: sortedPosts)

                } catch {
                    print("디코딩 에러:", error)
                }
            }
        }.resume()
    }
}


struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        VStack {
        }.navigationTitle("게시글")
    }
}

#Preview {
    CommunityView()
}

