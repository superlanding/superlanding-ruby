# Changelog

本檔記錄此專案所有值得注意的變更。

格式依循 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.1.0/)，版本號依循 [Semantic Versioning](https://semver.org/lang/zh-TW/)。

已發佈版本的日期以 [rubygems.org](https://rubygems.org/gems/superlanding) 為準。

## [Unreleased]

## [0.2.0] - 2026-10-27

> 此版本隨 PR #1 一起跳版號；**合併後才會由 `publish.yml` 發佈到 rubygems.org**。合併時請把日期改成實際合併日（發佈後以 rubygems.org 顯示為準）。

### Added

- 支援 Rails 7.0 / 7.1 / 7.2 / 8.0 / 8.1 與 Ruby 3.0 – 3.4（`activesupport >= 7.0, < 8.2`）；GitHub Actions 測試矩陣（`test.yml`）與 `gemfiles/`。
- 以本機假 HTTP server（`spec/support/fake_server.rb`）撰寫的 client / API base / response 測試，不連外部網路。
- GitHub Actions 自動發佈到 RubyGems（Trusted Publishing，`publish.yml`）。
- `CHANGELOG.md`、完整的 `README.md`，以及 `CLAUDE.md` 的發版與文件更新規則。

### Changed

- **Breaking：** `required_ruby_version` 改為 `>= 3.0`。
- 開發相依更新：`bundler >= 2.0`、`rake >= 13`、`minitest ~> 5.0`；不再追蹤 `Gemfile.lock`。

## [0.1.0] - 2018-12-21

### Added

- 初版：`SuperLanding::Client` 與 `statistic_items!` 的 API wrapper（`GET /statistic/items.json`），回傳 `SuperLanding::API::Response::StatisticItems`。

[Unreleased]: https://github.com/superlanding/superlanding-ruby/commits/master
[0.2.0]: https://rubygems.org/gems/superlanding
[0.1.0]: https://rubygems.org/gems/superlanding/versions/0.1.0
