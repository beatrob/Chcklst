# Chcklst project instructions

## Xcode build and test commands

- Xcode build and test commands for this project are pre-approved by the user.
- Run them with escalated sandbox access immediately so Xcode can access Simulator services, DerivedData, and Swift package caches. Do not first attempt them inside the restricted workspace sandbox.
- Use the existing approved `/bin/zsh -lc "xcodebuild ..."` command form for commands that capture and summarize logs. Do not ask the user for a separate confirmation when an existing approval rule matches.
- The standard test command is:

  ```sh
  /bin/zsh -lc "xcodebuild -project checklist.xcodeproj -scheme checklist -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO > /tmp/chcklst-nav-test.log 2>&1; test_status=$?; rg -n -C 2 \"error:|failed|passed|TEST SUCCEEDED|TEST FAILED|Executed\" /tmp/chcklst-nav-test.log | tail -260; exit $test_status"
  ```
