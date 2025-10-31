# Changelog

## 1.2.12 (2025-10-31)

- New: Remoting config handling, to allow specifying the settings used during invocation.

## 1.1.9 (2023-05-16)

- New: Command Write-AdcChangeLog - Writes a log entry for change objects.
- Upd: New-AdcChange - added `Data` parameter, to accept additional properties to include in the object.
- Upd: New-AdcChange - added `ToString` parameter, to allow overriding default display styles.

## 1.1.6 (2023-02-10)

- New: Command Compare-AdcProperty - Helper function simplifying the changes processing of Test-* commands.
- New: Command New-AdcChange - Create a new change object.

## 1.1.4 (2022-03-17)

- Upd: New Exchange CU Version definitions

## 1.1.3 (2021-03-04)

- New: Command Sync-AdcObject - Replicate a single item between DCs.
- New: Command Get-AdcExchangeVersion - Get a list of exchange versions and the various identifiers to see which has been deployed.
- Upd: Incremented PSFramework minimum version.

## 1.0.0 (2020-09-10)

- Initial Release
