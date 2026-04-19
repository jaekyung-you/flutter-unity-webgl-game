# Flutter × Unity WebGL — Tap Runner

> Flutter 앱 안에 Unity WebGL 게임을 임베드하고, 양방향 JavaScript 브리지로 연결한 포트폴리오 프로젝트입니다.

## 데모

| 로딩 → START | 게임 중 | GAME OVER |
|:---:|:---:|:---:|
| Flutter 오버레이가 Unity 위에 렌더링 | 실시간 점수 전송 (Unity → Flutter) | Flutter UI로 재시작 (Flutter → Unity) |

---

## 아키텍처

```
┌─────────────────────────────────────────────────────┐
│                  Flutter App (Dart)                  │
│                                                      │
│  ┌──────────────┐        ┌─────────────────────────┐ │
│  │  GamePage    │        │   Flutter Overlay UI     │ │
│  │  (Scaffold)  │        │  · Loading spinner       │ │
│  │              │        │  · START button          │ │
│  │  InAppWebView│        │  · Score display         │ │
│  │  (WebView)   │        │  · GAME OVER + RESTART   │ │
│  └──────┬───────┘        └────────────┬────────────┘ │
│         │                             │               │
│  InAppLocalhostServer                 │               │
│  (port 8080, Flutter assets)          │               │
└─────────┼─────────────────────────────┼───────────────┘
          │ HTTP                        │ setState()
          ▼                             │
┌─────────────────────┐                 │
│   index.html        │                 │
│   (Unity WebGL)     │◄────────────────┘
│                     │   JS Bridge
│  ┌───────────────┐  │
│  │ Unity Runtime │  │   Flutter → Unity
│  │  (WASM)       │  │   evaluateJavascript()
│  │               │  │   └─ window.flutterStartGame()
│  │  GameManager  │◄─┼──    window.flutterRestartGame()
│  │  PlayerCtrl   │  │      └─ unityInstance.SendMessage()
│  │  Spawner      │  │
│  │  Mover        │  │   Unity → Flutter
│  └───────┬───────┘  │   flutter_inappwebview.callHandler()
│          │           │   └─ onUnityReady
│  bridge.jslib        │   └─ onScoreUpdate(score)
│  (DllImport)         │   └─ onGameOver(finalScore, best)
└─────────────────────┘
```

### 브리지 흐름

| 방향 | 트리거 | 전달 경로 |
|------|--------|-----------|
| Flutter → Unity | START / RESTART 버튼 | `evaluateJavascript` → `window.flutterStartGame()` → `unityInstance.SendMessage('GameManager', ...)` |
| Unity → Flutter | 점수 업데이트 | C# `DllImport` → `bridge.jslib` → `callHandler('onScoreUpdate')` → Dart `setState` |
| Unity → Flutter | 게임 오버 | C# `DllImport` → `bridge.jslib` → `callHandler('onGameOver')` → Dart `setState` |

---

## 기술 스택

| 레이어 | 기술 |
|--------|------|
| 모바일 앱 | Flutter 3.x (Dart) |
| WebView | flutter_inappwebview ^6.1.5 |
| 게임 엔진 | Unity 6 (6000.4.3f1) |
| 빌드 타겟 | WebGL (compression=Disabled, threading=false) |
| JS 브리지 | Unity .jslib + InAppWebView JS Handler |
| 로컬 서버 | InAppLocalhostServer (port 8080) |

---

## 프로젝트 구조

```
flutter-unity-webgl-game/
├── unity-game/
│   ├── Assets/
│   │   ├── Scripts/
│   │   │   ├── GameManager.cs        # 게임 상태 관리, 점수, Flutter 브리지 DllImport
│   │   │   ├── PlayerController.cs   # Rigidbody2D 점프, 지면 감지, 충돌 처리
│   │   │   ├── ObstacleSpawner.cs    # 오브젝트 풀링, 속도 램프 (6→12 m/s over 30s)
│   │   │   ├── ObstacleMover.cs      # 좌측 스크롤, 풀 자동 반환
│   │   │   └── BackgroundScroller.cs # 두 패널 시차 스크롤
│   │   ├── Editor/
│   │   │   ├── SceneSetup.cs         # 씬 전체를 코드로 생성 (Inspector 불필요)
│   │   │   ├── WebGLBuildScript.cs   # WebGL 빌드 설정 적용
│   │   │   └── BatchBuild.cs         # -executeMethod CLI 진입점
│   │   └── Plugins/WebGL/
│   │       └── bridge.jslib          # Unity → Flutter JS 함수 정의
│   ├── Builds/WebGL/                 # 빌드 결과물 (35MB)
│   └── Packages/manifest.json        # com.unity.ugui 2.0.0 포함
│
└── flutter-app/
    ├── lib/
    │   ├── main.dart                 # 가로 orientation 고정, 앱 진입점
    │   └── game_page.dart            # WebView + JS 브리지 + Flutter 오버레이 UI
    ├── assets/unity/                 # Unity WebGL 빌드 복사본 (로컬 서버 제공용)
    │   ├── index.html                # 브라우저/Flutter 모드 분기, unityInstance 노출
    │   └── Build/                    # WebGL.loader.js / .framework.js / .data / .wasm
    ├── android/
    │   └── AndroidManifest.xml       # INTERNET 권한
    └── ios/
        └── Runner/Info.plist         # NSAllowsLocalNetworking
```

---

## 실행 방법

### 브라우저에서 Unity 게임만 확인

```bash
cd unity-game/Builds/WebGL
python3 -m http.server 9090
# http://localhost:9090 열기
```

### Flutter 앱 실행 (실기기 필요)

```bash
cd flutter-app
flutter pub get
flutter run    # USB로 연결된 iOS/Android 실기기 필요
```

> **주의**: iOS 시뮬레이터와 Android 에뮬레이터는 WebGL/WASM 하드웨어 가속을 지원하지 않아  
> Unity WebGL 로딩이 동작하지 않습니다. 실기기를 사용하세요.

### Unity 에서 씬 재생성 및 재빌드

```bash
# 씬 자동 생성
Unity → Build → Setup Game Scene

# WebGL 빌드
Unity → Build → Build WebGL

# 또는 CLI (batch mode)
/path/to/Unity -batchmode -projectPath unity-game \
  -executeMethod BatchBuild.BuildWebGL -quit -logFile build.log
```

---

## 핵심 구현 포인트

### 1. Unity WebGL 에셋 제공 방식
Flutter 앱 번들 내 에셋을 WebView에서 로드하기 위해 `InAppLocalhostServer`로 Flutter asset bundle을 HTTP로 제공합니다. 서버가 준비된 후에만 WebView를 렌더링해 race condition을 방지합니다.

```dart
// game_page.dart
await _localServer!.start();          // 서버 준비 완료 후
setState(() => _serverReady = true);  // 그때서야 WebView 렌더링
```

### 2. Unity → Flutter 점수 전송
```csharp
// GameManager.cs — C# DllImport
[DllImport("__Internal")]
private static extern void SendScoreToFlutter(int score);
```
```javascript
// bridge.jslib — JS 구현
SendScoreToFlutter: function(score) {
  window.flutter_inappwebview.callHandler('onScoreUpdate', score);
}
```

### 3. Flutter → Unity 게임 제어
```dart
// game_page.dart
_webController?.evaluateJavascript(source: 'window.flutterStartGame();');
```
```javascript
// index.html
window.flutterStartGame = function() {
  window.unityInstance.SendMessage('GameManager', 'OnFlutterStartGame', '');
};
```

---

## 알려진 제한사항

- Android 에뮬레이터 / iOS 시뮬레이터에서 Unity WebGL 미동작 (GPU 가속 필요)
- Unity WebGL 초기 로딩 시간: 실기기 기준 약 10~20초 (WASM 29MB)
- WebGL compression 비활성화 상태 (Flutter asset server가 Content-Encoding 헤더를 설정하지 않으므로)
