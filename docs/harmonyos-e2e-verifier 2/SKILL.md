---
name: harmonyos-e2e-verifier
description: Implement and verify HarmonyOS 5.0.0+ application changes end to end. Use for ArkTS, ArkUI, Ability, ArkData, Preferences, relational database, navigation, state refresh, CRUD, or UI behavior changes where a successful build alone is not sufficient.
---

# HarmonyOS End-to-End Verifier

Treat compilation as the first verification gate, never as proof that a change works.

Complete the implementation and then verify the changed user journey on HarmonyOS 5.0.0 or later. Prefer the project's existing commands, modules, products, test framework, fixtures, and device configuration. Inspect the repository before choosing commands; do not invent module names, bundle names, database paths, UI identifiers, or credentials.

## Definition of done

A change is complete only when all applicable gates pass:

1. The affected product and module build successfully.
2. Existing relevant Local Tests pass.
3. New or changed business logic has focused tests when it can be tested locally.
4. Persistence is exercised through the real repository or data-access path, not only with a mocked return value.
5. The changed UI journey is run on an available HarmonyOS 5.0.0+ emulator or device.
6. After navigation, return, foregrounding, or reopening, displayed data matches the authoritative data source.
7. Loading, empty, success, error, duplicate-action, and rapid-navigation behavior relevant to the change are checked.
8. The final report contains commands, environment, scenarios, expected and observed results, and evidence for failures or skipped checks.

Do not claim completion when only the build passed. Do not silently skip a gate. A skipped gate must be marked `BLOCKED` or `NOT APPLICABLE` with a concrete reason.

## 1. Discover the project

Before editing or testing, identify:

- HarmonyOS SDK/API target and compatible SDK version;
- application product, module, bundle name, and entry ability;
- `hvigorw` location and the build/test tasks already used by the project or CI;
- test folders and test registration files such as `List.test.ets`;
- navigation mechanism, page lifecycle callbacks, and state owner;
- persistence technology: Preferences, relationalStore/RDB, KV store, file storage, network cache, or another source;
- available emulator/device and its system/API version;
- existing UI-test framework, test IDs, accessibility text, fixtures, and cleanup helpers.

Record the selected values in the verification report.

## 2. Build gate

Run the narrowest existing build that covers the changed product, then run the project's normal release-quality or CI build if available. Use the repository's wrapper and configuration.

If the build fails, diagnose and fix failures caused by the change. Do not erase unrelated user changes or weaken compiler, lint, signing, or type checks merely to obtain a green build.

## 3. Automated test gate

Run the project's relevant tests. For Local Test projects, the standard command shape is:

```bash
./hvigorw test -p module=<actual-module> -p coverage=true
```

Use the Windows wrapper when appropriate. Supply only project-confirmed module, product, suite, and method values.

Add focused tests for changed rules, mapping, validation, repository behavior, and state transitions. Assert observable outcomes and invariants rather than generated wording or implementation details. Report the test-result and coverage-report paths when produced.

## 4. Database and persistence gate

Test the actual persistence boundary used by the application.

For each changed CRUD path that applies:

1. Establish a known initial state with isolated test data.
2. Perform the action through the repository/service used by production code.
3. Query the authoritative store independently and verify row count, keys, field values, ordering, timestamps, and relationships.
4. Reopen the store or restart/relaunch the app when persistence across sessions is part of the behavior.
5. Verify update and delete behavior, including missing records and duplicate submissions where relevant.
6. Close every `ResultSet` and database resource and remove only the test data created by this run.

Do not treat an in-memory UI state change as proof that the database was updated. Do not inspect or mutate a production database. Prefer a debug build, test database, transaction rollback, or uniquely prefixed fixture records.

When relationalStore is used, capture SQLite errors if the app already exposes `sqliteErrorOccurred`, and include the relevant sanitized error in the report. Never print secrets, encryption keys, tokens, or unrelated user records.

## 5. Device and UI journey gate

Use an available HarmonyOS 5.0.0+ emulator or debug device. Confirm the target with `hdc` or the project's existing device tooling before installation or execution. If no compatible target is available, continue with build and local tests, but mark device verification `BLOCKED`; never simulate a pass in prose.

Install and launch the debug application using existing project/IDE tasks. Exercise the changed journey using the project's UI tests when available; otherwise perform a reproducible manual device run and capture concise evidence.

For every affected data-driven screen, verify at least this sequence:

1. Open screen A and note its visible data.
2. Navigate to screen B.
3. Create, update, or delete a uniquely identifiable test record on B.
4. Return to A using the actual user navigation path.
5. Verify A refreshes and shows the new authoritative value exactly once, without requiring an unrelated extra action.
6. Navigate away and back again to detect stale caches, duplicate subscriptions, and duplicated rows.
7. Background and foreground the app if the feature promises lifecycle refresh.
8. Relaunch the app if the data is expected to persist.

Also check applicable variants:

- empty to populated and populated to empty;
- save failure followed by retry;
- fast double tap or repeated save;
- rapid A -> B -> A navigation while an async query is pending;
- loading indicator termination and error visibility;
- list/detail consistency after update or deletion;
- state preservation versus intentional refresh;
- no crash, frozen UI, duplicate observer, or late async write into a destroyed page.

Prefer stable UI identifiers or accessibility-visible text over screen coordinates and arbitrary delays. Wait for observable state with a bounded timeout. A screenshot alone proves appearance, not persistence; pair UI evidence with a store query or relaunch when persistence is under test.

## 6. Refresh correctness

Trace the complete refresh chain:

```text
user action -> write result -> state invalidation/event -> lifecycle or subscription -> query -> state update -> ArkUI render
```

Verify that:

- navigation does not reuse stale page-local state unintentionally;
- refresh happens after a successful write, not before commit completion;
- a failed write does not display committed success state;
- async responses cannot overwrite newer state;
- subscriptions/listeners are registered once and released at the correct lifecycle boundary;
- refresh does not create duplicate rows or repeated network/database calls;
- the UI and database agree after returning, foregrounding, and relaunching where applicable.

## 7. Evidence and final report

End with a compact verification matrix:

| Gate | Status | Command or scenario | Evidence / observed result |
|---|---|---|---|
| Build | PASS/FAIL/BLOCKED/N/A | exact command | relevant output |
| Local tests | PASS/FAIL/BLOCKED/N/A | exact command | counts and report path |
| Database | PASS/FAIL/BLOCKED/N/A | fixture and query | expected versus actual |
| UI navigation | PASS/FAIL/BLOCKED/N/A | A -> B -> A journey | refresh result |
| Lifecycle/relaunch | PASS/FAIL/BLOCKED/N/A | scenario | persistence result |

List remaining risks and unverified items. Say `verified` only for checks actually executed in this run. If any required gate is `FAIL` or `BLOCKED`, state that the change is not fully verified.

