# 3. Drift SQLite Offline-First Persistence Architecture

**Context & Decision**: 
The NCD screening field operations by Village Health Volunteers (VHV) in rural and mountainous areas of Mae Ai District frequently occur in areas with limited or zero internet connectivity. To provide seamless data recording, deterministic state persistence, and full relational integrity across app restarts, we adopted **Drift (formerly Moor)** as the primary local relational SQLite database engine. 

`DriftNcdRepository` implements `NcdRepositoryInterface`, supporting relational tables (`VillagesTable`, `NursesTable`, `VhvsTable`, `PatientsTable`, `ScreeningsTable`, `ScreeningHistoriesTable`, `ScreeningResultsTable`) with ACID transactions, reactive stream queries, and automated database seeding on initial install.

**Consequences**:
- Reliable offline data storage: Patients, screenings, and nurse review approvals persist across app lifecycles.
- Future-ready for Remote Sync: The repository seam allows easily plugging in a remote synchronization queue without refactoring UI or BLoC layers.
- Code generation overhead: Requires running `build_runner` when modifying Drift table schemas or query definitions.
