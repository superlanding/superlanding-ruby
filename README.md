# superlanding-ruby

[一頁商店 SuperLanding](https://www.super-landing.com) API 的 Ruby client（gem 名稱 `superlanding`）。目前提供 **統計商品（statistic items）** API：依 `member_base_ids` 查詢商品的欠貨數量與 3 / 7 / 30 天銷量。

版本異動請見 [CHANGELOG.md](CHANGELOG.md)。

## 需求

| | 支援 |
| --- | --- |
| Ruby | 3.0、3.1、3.2、3.3、3.4 |
| Rails（`activesupport`） | 7.0、7.1、7.2、8.0、8.1 |

Rails 7.2 需要 Ruby >= 3.1，Rails 8.0 / 8.1 需要 Ruby >= 3.2；CI（`.github/workflows/test.yml`）就是跑這些組合。執行期相依：`rest-client`、`activesupport >= 7.0, < 8.2`（只用到 `delegate`，不需要整個 Rails）。

## 安裝

在 `Gemfile` 加入：

```ruby
gem "superlanding", ">= 0.2.0"
```

然後執行：

```sh
bundle install
```

> 支援 Ruby 3 / Rails 7+ 的版本是 **0.2.0**。若 rubygems.org 上還沒有 0.2.0（請看 [CHANGELOG](CHANGELOG.md)），可先用 Git 來源：
> `gem "superlanding", github: "superlanding/superlanding-ruby"`。

不使用 bundler 時：`gem install superlanding`，再 `require "super_landing"`（注意 require 名稱是 `super_landing`，Bundler 會依 gem 名稱自動 require `superlanding`，不會載入；Rails 專案請寫 `gem "superlanding", require: "super_landing"`）。

## 設定

向一頁商店取得 **商家代碼（merchant_no）** 與 **access key**，建立 client：

```ruby
client = SuperLanding::Client.new("MERCHANT_NO", "ACCESS_KEY")
```

第三個參數可覆寫 API 網址（預設 `SuperLanding::BASE_URL` = `https://www.super-landing.com/api`），例如指到測試環境：

```ruby
client = SuperLanding::Client.new("MERCHANT_NO", "ACCESS_KEY", "https://staging.example.com/api")
```

請勿把 access key 寫死在程式碼或提交到版本庫，建議放在 Rails credentials 或環境變數。

## 使用方式

### 統計商品

```ruby
response = client.statistic_items!([28]) # 參數是 member_base_ids 陣列

response.code     # => 200（HTTP 狀態碼）
response.auth?    # => true（只有 HTTP 200 才是 true）
response.length   # => 商品筆數
response.data     # => 解析後的 JSON（Array of Hash，欄位依伺服器回傳）
```

實際送出的請求是 `GET {base_url}/statistic/items.json?merchant_no=…&access_key=…&member_base_ids=28`；多個 id 會以重複的 `member_base_ids` 參數送出（`[28, 29]` → `member_base_ids=28&member_base_ids=29`）。

`response` 可以直接 `each` / `map` / `each_with_index` / `length`（委派給 `response.items`）。商品的欄位順序為 `code, title, owe_qty, day3, day7, day30, day3_avg, day7_avg, day30_avg`。

非 200（例如 401 認證失敗）時，`auth?` 為 `false`、`items` 為空陣列，`response.data` 仍是伺服器回傳的 JSON，可用來讀取錯誤訊息。

### 已知限制

- `Response::StatisticItems` 目前以 `Item.new(item.values)` 建立 Struct，導致整個陣列被放進第一個欄位：`item.code` 會是 `["A1", "T", 1, …]` 而不是 `"A1"`，其他欄位為 `nil`。**請改用 `response.data`**（Hash 陣列）取值，例如 `response.data.map { |h| h["code"] }`。這是既有行為，此 gem 尚未修正（見 `spec/api/response_spec.rb` 的 skip）。
- 回應不是合法 JSON（例如伺服器 5xx 回傳純文字）時，`JSON::ParserError` 會直接拋出。
- 目前只有 `statistic_items!`；`API::Order` 與 `Response::Order` 僅是空的骨架。

## 開發與測試

```sh
git clone https://github.com/superlanding/superlanding-ruby.git
cd superlanding-ruby
BUNDLE_GEMFILE=gemfiles/rails_8.1.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_8.1.gemfile bundle exec rake t
```

依你的 Ruby 版本從 `gemfiles/`（`rails_7.0` … `rails_8.1`）挑一個。測試是 Minitest（`spec/**/*_spec.rb`），透過 `spec/support/fake_server.rb` 的本機假 HTTP server（127.0.0.1、隨機 port）跑完整的 RestClient 流程，**不會連外部網路**。`SUPERLANDING_LIVE=1` 才會執行需要本機開發 server 的測試；`COVERAGE=1` 會啟用 SimpleCov。

## 發版

合併到 `master` 後自動發佈（RubyGems [Trusted Publishing](https://guides.rubygems.org/trusted-publishing/)，不儲存 API key）：

1. 在 PR 裡修改 `lib/super_landing/version.rb` 的 `SuperLanding::VERSION`（SemVer），並把 `CHANGELOG.md` 的 `Unreleased` 內容移到新的 `## [x.y.z] - YYYY-MM-DD` 章節。
2. 合併 PR 到 `master`。
3. `.github/workflows/publish.yml` 發現 rubygems.org 上還沒有這個版本，就會建置 gem 並執行 `rake release`（發佈並建立 `vx.y.z` tag）；版本已存在則什麼都不做。

沒有跳版號的 PR（文件、CI）不會發佈。

## 貢獻

歡迎在 GitHub 回報問題與發 PR：https://github.com/superlanding/superlanding-ruby 。每個 PR 都必須同步更新 README（行為／用法／需求有變時）並在 `CHANGELOG.md` 補一筆，詳見 `CLAUDE.md`。

## 授權

以 [MIT License](LICENSE.txt) 釋出。
