# 1. Offline-First Repository Architecture with Mock Seeding

**Context & Decision**: 
The NCD Screening Mobile App needs to function smoothly for demonstrations, testing, and field use where network connectivity at Mae Ai subdistrict health center (รพ.สต.แม่อาย) may be unstable. We decided to implement an offline-first repository pattern backed by in-memory & local mock persistence initialized with domain seed data (villages, patients, VHV, nurses, standard screening questions).

**Consequences**:
- Immediate testing and demo capabilities without needing an active live backend server.
- Clear contract interfaces (`PatientRepository`, `VhvRepository`, `ScreeningRepository`, `AuthRepository`) allowing seamless transition to real RESTful APIs (`Dio`/HTTP) later.
- Fast execution speed and zero flaky network failures during presentation.
