// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Alamofire
import SwiftSoup

struct NewsItem: Codable {
    let title: String
    let link: String
    let source: String
}

class NewsScraper {
    private func fetchHTML(from url: String, completion: @escaping (String?) -> Void) {
        let request = AF.request(url)
        print("Fetching HTML from \(url)...")
        request.responseString { response in
            switch response.result {
            case .success(let html):
                print("Successfully fetched HTML.")
                completion(html)
            case .failure(let error):
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    private func parseHTML(_ html: String) -> [NewsItem] {
        do {
            print("Parsing HTML...")
            let document = try SwiftSoup.parse(html)
            let elements = try document.select("div.section_latest_article._CONTENT_LIST._PERSIST_META ul li")
            
            var results: [NewsItem] = []
            
            for element in elements.prefix(5) {
                let title = try element.select("div.sa_text > a > strong").text()
                let link = try element.select("div.sa_text > a").attr("href")
                let source = try element.select("div.sa_text > div.sa_text_info > div.sa_text_info_left > div.sa_text_press").text()

                results.append(NewsItem(title: title, link: link, source: source))
            }
            
            return results
        } catch {
            print("Error parsing HTML: \(error)")
            return []
        }
    }

    private func saveToFile(data: [NewsItem]) {
        let fileManager = FileManager.default
        let scrapDirectory = fileManager.currentDirectoryPath + "/scrap"
        
        do {
            if !fileManager.fileExists(atPath: scrapDirectory) {
                try fileManager.createDirectory(atPath: scrapDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmm"
            let dateString = dateFormatter.string(from: Date())
            let filePath = scrapDirectory + "/headlines_\(dateString).json"
            
            var text = ""
            for item in data {
                text += "[\(item.source)] <\(item.link)|\(item.title)>\n"
            }
            
            let json: [String: String] = ["text": text]
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                try jsonString.write(toFile: filePath, atomically: true, encoding: .utf8)
                print("Headlines saved to \(filePath)")
            } else {
                print("Error converting JSON data to string")
            }
        } catch {
            print("Error saving headlines: \(error)")
        }
    }

    func run() {
        let url = "https://news.naver.com/breakingnews/section/105/731"
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchHTML(from: url) { html in
            defer { dispatchGroup.leave() }
            guard let html = html else {
                print("Failed to fetch HTML")
                return
            }
            
            let headlines = self.parseHTML(html)
            for headline in headlines {
                print("Title: \(headline.title), Link: \(headline.link), Source: \(headline.source)")
            }
            
            self.saveToFile(data: headlines)
        }
        
        dispatchGroup.notify(queue: .main) {
            print("All tasks completed.")
            // 프로그램 종료
            exit(EXIT_SUCCESS)
        }
        
        dispatchMain()  // 메인 디스패치 큐에서 대기
    }
}

let notifier = NewsScraper()
notifier.run()
