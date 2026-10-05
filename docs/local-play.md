# Local Play

Create a local account with your own username and password, then enter your business name.

Accounts and progress last only while the app is open. Sign out to switch players; closing the app clears all local alpha state.

The Flutter frontend can be launched from the repository root once Flutter desktop/mobile platform support is generated/configured on the development machine.

Typical Linux development flow:

```bash
git clone https://github.com/ProblemTechs/TruckManager.git
cd TruckManager
git checkout backend/player-accounts-and-commands
flutter create --platforms=linux .
flutter pub get
flutter run -d linux
```

`flutter create --platforms=linux .` is intended only to generate missing platform runner folders for this early repository. Review generated files before committing them.

For Android, use an Android emulator or connected Android device and `flutter run` after Android SDK/device setup. iOS builds require macOS/Xcode.

The repository is still a development build: backend domain systems exist, but frontend screens must be fully wired to `TruckGameState`/backend services before it should be treated as a complete playable beta.

For the first playable loop, use Settings to buy a cargo van ($48,000) and hire a driver ($1,000), then use Loads to accept and complete a starter load.
