# Add UDF to OCRB (Business Partner Bank Accounts) — Runbook

## Why this script exists
SAP B1's *User-Defined Fields — Management* UI does **not** expose the **OCRB** node
(Business Partner Bank Accounts). The supported way to add a UDF is via the DI API.
Direct `ALTER TABLE` on HANA is **NOT** safe (see CINF.Version incident on
SBO_FIXEDASSET that broke B1 login with error 130-4).

## Where to run
- Host: **`10.21.100.32`** (RDP box, user `sldsupport01` / `Sld@1234`)
- This host has SAP B1 Client Tools + DI API installed
- The script will refuse to run if `Interop.SAPbobsCOM.dll` is not found

## How to run

1. RDP to `10.21.100.32` as `sldsupport01`.
2. Copy `Add-UDF-OCRB.ps1` to the box (e.g. `C:\Temp\Add-UDF-OCRB.ps1`).
3. Open **PowerShell as Administrator** (DI API COM registration usually requires it).
4. Allow script execution for this session:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```
5. Run one of the examples below.

## Examples

### Add a text remark field (100 chars)
```powershell
cd C:\Temp
.\Add-UDF-OCRB.ps1 `
    -FieldName  "RemarkAP" `
    -Description "หมายเหตุ AP" `
    -Type Alpha `
    -Size 100
```

### Add a date field
```powershell
.\Add-UDF-OCRB.ps1 -FieldName "ApproveDate" -Description "วันที่อนุมัติ" -Type Date
```

### Add a numeric/integer field
```powershell
.\Add-UDF-OCRB.ps1 -FieldName "Priority" -Description "ลำดับ" -Type Numeric -Size 5
```

### Add a long-text (Memo) field
```powershell
.\Add-UDF-OCRB.ps1 -FieldName "Notes" -Description "หมายเหตุยาว" -Type Memo
```

### Override defaults (different company / non-manager user)
```powershell
.\Add-UDF-OCRB.ps1 `
    -FieldName "RemarkAP" -Description "หมายเหตุ AP" -Type Alpha -Size 100 `
    -CompanyDB SBO_ENCONFUND_TEST `
    -B1User manager
# script will prompt securely for the B1 password
```

## Parameter cheatsheet

| Param         | Default                  | Notes                                                      |
|---------------|--------------------------|------------------------------------------------------------|
| `-FieldName`  | (required)               | Stored as `U_<FieldName>` — no `U_` prefix in the arg     |
| `-Description`| (required)               | UI label, Thai OK                                          |
| `-Type`       | `Alpha`                  | `Alpha\|Numeric\|Date\|Memo\|Float\|Price\|Quantity`       |
| `-Size`       | 100 (Alpha) / 11 (Numeric) | EditSize; ignored for Date/Memo                          |
| `-Server`     | `10.21.100.31:30015`     | HANA server:port                                           |
| `-CompanyDB`  | `SBO_ENCONFUND_BUDGET`   | Target company DB                                          |
| `-DbUser`     | `SYSTEM`                 | HANA DB user                                               |
| `-DbPassword` | `Enc0nfund`              | HANA DB password (consider passing via env in prod)        |
| `-B1User`     | `manager`                | B1 application user                                        |
| `-B1Password` | (prompted)               | Secure prompt if omitted                                   |

## Verify after run

1. Login to B1 client.
2. *Business Partner* → *Business Partner Master Data* → open any BP.
3. *Payment Terms* tab → click *Bank Accounts*.
4. Right-click the row header → *Form Settings* → *Table Format* tab.
5. `U_<FieldName>` should appear and be toggleable to visible.

You can also sanity-check on HANA:
```sql
SELECT "TableID","AliasID","Descr","FieldType","SizeID"
FROM   SBO_ENCONFUND_BUDGET.CUFD
WHERE  "TableID" = 'OCRB'
ORDER  BY "FieldID" DESC;
```

## Troubleshooting

| Symptom                                        | Likely cause / fix                                                                 |
|------------------------------------------------|------------------------------------------------------------------------------------|
| `Interop.SAPbobsCOM.dll not found`             | Run on `10.21.100.32`, not your laptop. Install B1 Client Tools if missing.       |
| `Connect failed. code=-111`                    | Wrong B1 password / no DI API license slot. Free a session or use another user.   |
| `Connect failed. code=-119`                    | Wrong HANA user/password or company DB name.                                       |
| `Add() failed ... already exists`              | UDF already there — script exits 0 with a warning. Safe.                          |
| `Set-ExecutionPolicy ... is not allowed`       | Run PowerShell **as Administrator**, then retry the Bypass command.                |
| `Class not registered (0x80040154)`            | DI API not registered — reinstall SAP B1 Client Tools / DI API on the host.        |

## Hard rules

- **Never** `ALTER TABLE` on HANA to add columns to B1 system tables. DI API only.
- **Never** modify `CINF` or `CINF.Version` (see prior incident — broke B1 login).
- Always test on `SBO_ENCONFUND_TEST` first if available; `BUDGET` may be production.
