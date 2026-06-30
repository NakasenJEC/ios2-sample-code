// ============================================
// 第8章：ウィジェットを作る
// ============================================
// 今日の名言をホーム画面に表示するウィジェットです。
// メインアプリとウィジェットの両方のコードを含みます。
//
// 【セットアップ手順】※最新のXcodeのウィジェットテンプレートに対応
//
// 1. Xcodeで File → New → Target → Widget Extension を選ぶ
//    ・名前（Product Name）は「QuoteWidget」にする
//    ・「Include Live Activity」と「Include Configuration App Intent」は
//      どちらもチェックを外す（後で消すファイルが減る。外せなくても手順2で消すのでOK）
//
// 2. 追加すると、プロジェクトに「QuoteWidget」フォルダができ、中に複数の
//    Swift ファイルが自動生成される。今回の名言ウィジェットに必要なのは
//    QuoteWidget.swift の 1本だけ。残りの QuoteWidget〜.swift は全部削除する
//    （ファイルを選び 右クリック → Delete → 「Move to Trash」）。
//    消す対象の例（生成された分だけ）：
//      ・QuoteWidgetBundle.swift      … @main が入っている「入口」。複数ウィジェットを
//                                        束ねる役割だが、今回はウィジェット1個なので不要
//      ・QuoteWidgetControl.swift     … コントロールセンター用ウィジェット（不要）
//      ・QuoteWidgetLiveActivity.swift … ライブアクティビティ用（生成された場合のみ）
//    → QuoteWidget フォルダに残す Swift ファイルは QuoteWidget.swift だけ、が目印。
//
// 3. データ型を共有する（Quote と QuoteStore の "両方"）：
//    ・新規ファイル QuoteStore.swift を作り、Quote 構造体と QuoteStore 構造体の
//      両方をそこに移す（ウィジェット側は Quote 型も使うため、片方だけでは
//      「Cannot find 'Quote' in scope」になる）
//    ・この ContentView.swift 側からは Quote と QuoteStore の定義を削除する
//      （両方に同じ定義が残ると「Invalid redeclaration」になる）
//    ・QuoteStore.swift を選び、右側インスペクタの Target Membership で
//      「メインアプリ」と「QuoteWidget Extension」の両方にチェックを入れる
//
// 4. ウィジェット本体を置き換える：
//    ・手順2で残した QuoteWidget.swift を開き、中身を「すべて削除」してから、
//      このファイル末尾の「ウィジェット側のコード」を貼り付ける
//      （先頭と末尾の /* */ は外す）
//    ・貼り付けるコードには @main の付いた QuoteWidget が入っている。手順2で
//      @main を持つ QuoteWidgetBundle.swift を削除済みなので、これがエクステン
//      ションで唯一の @main になる
//    ・QuoteWidgetBundle.swift を消し忘れると @main が二重になり
//      「'main' attribute can only apply to one type」エラーになる
//
// ※ App Group の設定は不要です（Quote / QuoteStore は静的データのため、
//   UserDefaults や共有ファイルでのデータ受け渡しを行いません）
// ============================================

// ============================================
// ■ メインアプリ側のコード（ContentView.swift）
// ============================================

import SwiftUI

// MARK: - 名言データ（アプリとウィジェットで共有）

struct Quote: Identifiable, Codable {
    let id: Int
    let text: String
    let author: String
}

struct QuoteStore {
    static let quotes: [Quote] = [
        Quote(id: 1, text: "為せば成る、為さねば成らぬ何事も", author: "上杉鷹山"),
        Quote(id: 2, text: "千里の道も一歩から", author: "老子"),
        Quote(id: 3, text: "継続は力なり", author: "ことわざ"),
        Quote(id: 4, text: "失敗は成功のもと", author: "ことわざ"),
        Quote(id: 5, text: "知ることは愛することの始まりである", author: "ことわざ"),
        Quote(id: 6, text: "学びて思わざれば則ち罔し", author: "孔子"),
        Quote(id: 7, text: "過ちて改めざる、是を過ちと謂う", author: "孔子"),
    ]

    static func todaysQuote() -> Quote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % quotes.count
        return quotes[index]
    }
}

// MARK: - メインアプリのContentView

struct ContentView: View {
    let todaysQuote = QuoteStore.todaysQuote()
    @State private var allQuotes = QuoteStore.quotes

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 今日の名言（ハイライト）
                VStack(spacing: 16) {
                    Text("今日の名言")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("「\(todaysQuote.text)」")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("— \(todaysQuote.author)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.blue.opacity(0.08))
                )
                .padding(.horizontal)

                // 全名言リスト
                List(allQuotes) { quote in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(quote.text)
                            .font(.body)
                        Text("— \(quote.author)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("名言集")
        }
    }
}

#Preview {
    ContentView()
}


// ============================================
// ■ ウィジェット側のコード（自動生成された QuoteWidget.swift を "全置換"）
// ============================================
// ※ 下の /* ... */ を外し、自動生成ファイルの中身を全部消してから貼り付けます。
// ※ Quote と QuoteStore は手順3で QuoteStore.swift に移し、両ターゲットの
//    Target Membership に入れてあるので、ここでは再定義しません。
// ============================================

/*
import WidgetKit
import SwiftUI

// MARK: - タイムラインエントリ

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: Quote
}

// MARK: - タイムラインプロバイダ

struct QuoteProvider: TimelineProvider {
    // プレースホルダー（読み込み中の仮表示）
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(
            date: Date(),
            quote: Quote(id: 0, text: "読み込み中...", author: "")
        )
    }

    // スナップショット（ウィジェットギャラリーでのプレビュー）
    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        let entry = QuoteEntry(
            date: Date(),
            quote: QuoteStore.todaysQuote()
        )
        completion(entry)
    }

    // タイムライン（実際のウィジェット更新スケジュール）
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let currentDate = Date()
        let quote = QuoteStore.todaysQuote()
        let entry = QuoteEntry(date: currentDate, quote: quote)

        // 次の日の0時にウィジェットを更新
        let tomorrow = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        )

        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

// MARK: - ウィジェットのビュー

struct QuoteWidgetEntryView: View {
    var entry: QuoteProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            mediumWidget
        }
    }

    // 小サイズ
    var smallWidget: some View {
        VStack(spacing: 4) {
            Image(systemName: "quote.opening")
                .font(.caption)
                .foregroundStyle(.blue)

            Text(entry.quote.text)
                .font(.caption)
                .bold()
                .multilineTextAlignment(.center)
                .lineLimit(3)

            Text(entry.quote.author)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
    }

    // 中サイズ
    var mediumWidget: some View {
        HStack(spacing: 16) {
            Image(systemName: "quote.opening")
                .font(.title)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("今日の名言")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(entry.quote.text)
                    .font(.subheadline)
                    .bold()

                Text("— \(entry.quote.author)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - ウィジェット定義

@main
struct QuoteWidget: Widget {
    let kind: String = "QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            QuoteWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("今日の名言")
        .description("日替わりで名言を表示します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - プレビュー

#Preview(as: .systemMedium) {
    QuoteWidget()
} timeline: {
    QuoteEntry(date: .now, quote: QuoteStore.todaysQuote())
}
*/
