# Change Log

## release_903...release_906
### Changed
- QuotaCriticalEvent primary key modified to include `occurrence_timestamp` fixes 2015-01-02 sync issue
- A-Z fixed with move to serializers for the api
- Increase the retries count and sleep time between failed downloads

### Added
- rake task for [budler-audit](https://github.com/rubysec/bundler-audit)

## release_878...release_903
### Changed
- Upgraded Rails to 4.1.8 from 3.2.17
- Upgraded Ruby to 2.1.4 from 2.0.0
- Replacing redis lock with an implementation that does not expire if work is in progress
- SSL 3.0 removed for tariff update file downloading
- Minor formatting fix for duty expressions
- Fixing ME1 conformance validation

### Added
- Logging of conformance errors in admin
- Retry downloading of files
- trade-tariff-suite specs which were not covered in the backend specs

### Removed
- Front end code (as backend only serves API)
- DB locking code (we moved to a redis lock)