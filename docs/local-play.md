# Local Play

Default development player name: **ProblemTechs**.

The Flutter frontend can be launched from the repository root once Flutter desktop/mobile platform support is generated/configured on the development machine.

Typical Linux development flow:

```bash
git clone https://github.com/ProblemTechs/TruckManager.git
cd TruckManager
git checkout backend/gameplay-v0.2
flutter create .
flutter pub get
flutter run -d linux
```

`flutter create .` is intended only to generate missing platform runner folders for this early repository. Review generated files before committing them.

For Android, use an Android emulator or connected Android device and `flutter run` after Android SDK/device setup. iOS builds require macOS/Xcode.

The repository is still a development build: backend domain systems exist, but frontend screens must be fully wired to `TruckGameState`/backend services before it should be treated as a complete playable beta.
