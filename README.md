# Rokid Search Helper iOS

iOS companion search assistant for Rokid AR glasses.  
Converted from the [Android original](https://github.com/zxy7906052/RokidSearchHelper).

## What it does

- Type any question into the search bar
- Gets instant answers from **DuckDuckGo Instant Answers** (free, no API key needed)
- Falls back to an **OpenAI-compatible AI** if no instant answer is found (optional, configurable)
- Results are displayed in a **glasses-optimized high-contrast card** (large font, dark background, green border)
- Search history is saved locally
- Results are also broadcast via **TCP on port 8081** for future custom glasses-side companion apps

## Android vs iOS differences

| Feature | Android original | iOS version |
|---------|-----------------|-------------|
| Glasses connection | Rokid CxrApi SDK (Bluetooth) | TCP Wi-Fi server on port 8081 |
| Custom UI on glasses | `CxrApi.openCustomView(json)` | Not available (CxrApi is Android-only) |
| Search | Hardcoded demo answer | Real DuckDuckGo + AI answers |
| Audio from glasses | `CxrApi.openAudioRecord()` | Not available |

> The Rokid CxrApi SDK is proprietary Android-only. On iOS, results are displayed on the phone screen in a glasses-friendly format. A custom glasses-side companion app could connect to the TCP server on port 8081 to receive results.

## File Reference

| File | Purpose |
|------|---------|
| `Data/Settings.swift` | `Settings` struct + `SettingsStore` (UserDefaults persistence) |
| `Data/SearchHistory.swift` | `SearchEntry` model + `SearchHistory` (last 50 entries) |
| `Service/DuckDuckGoService.swift` | DuckDuckGo Instant Answers API (Abstract, Answer, Definition, RelatedTopics) |
| `Service/OpenAiSearchService.swift` | OpenAI-compatible chat completions for AI fallback |
| `Glasses/GlassesDisplayServer.swift` | `NWListener` TCP server, broadcasts results as JSON on port 8081 |
| `ViewModel/SearchViewModel.swift` | Orchestrates search pipeline, updates history, broadcasts to glasses |
| `UI/ContentView.swift` | TabView root: Search / History / Settings |
| `UI/SearchView.swift` | Search bar + result display + recent history chips |
| `UI/ResultCardView.swift` | High-contrast answer card (configurable font size & contrast) |
| `UI/HistoryView.swift` | Scrollable history list with tap-to-re-search |
| `UI/SettingsView.swift` | Display options, AI API key, glasses TCP info |

## Xcode Setup

1. Open `RokidSearchHelper.xcodeproj` in Xcode 15+
2. Select your Team under **Signing & Capabilities**
3. Build & run on iPhone (iOS 16+)

No third-party dependencies — uses only:
- `Network.framework` — NWListener TCP server
- `Foundation` — URLSession for DuckDuckGo and OpenAI APIs

## Search pipeline

```
Query
  └─ DuckDuckGo Instant Answers (free, always tried first)
       └─ AbstractText (Wikipedia summary)
       └─ Answer (instant facts)
       └─ Definition
       └─ RelatedTopics[0]
  └─ OpenAI-compatible fallback (optional, requires API key)
  └─ "No answer found" error state
```

## TCP broadcast format

```json
{ "type": "search_result", "query": "...", "answer": "...", "source": "..." }
{ "type": "clear" }
```
