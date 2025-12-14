# Changelog

## [0.1.3.0] - 2025-01-XX

### Changed
- Disabled 5-ada-only check for reserved collateral in `runTx`, allowing reserved collateral to be used regardless of its value, as per CIP 40 changes

## [0.1.2.0] - 2025-01-XX

### Fixed
- Fixed `mkInteractionTxBody` to use `reservedCollateral` from `userAddresses` instead of hardcoded `Nothing`, preventing `GYNoSuitableCollateralException` when no collateral is explicitly provided

## [0.1.1.0] - 2025-01-XX

### Removed
- Removed `ActionType` data type from `TxBuilding.Types`

## [0.1.0.0] - 2025-01-XX

### Added
- Initial release
- Core transaction building types and context
- MonadInteraction class for transaction building
- Instances for GYTxQueryMonadIO and GYTxBuilderMonadIO



