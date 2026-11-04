# Dataset and download sizes

Metadata snapshot UTC: 2026-11-04T07:52:53.395035+00:00. Decimal GB = bytes / 1,000,000,000; MB = bytes / 1,000,000. Exact integers are in the CSV.

| Dataset | Download size | Final expansion | Retained all levels | Distribution |
| --- | ---: | ---: | ---: | --- |
| All company raw archives (alternative delivery) | 42.152 GB | 246.562 GB | 288.714 GB | available_on_request; measured |
| All sector raw archives | 42.152 GB | 246.565 GB | 330.869 GB | available_on_request; measured |
| MD&A narrative and scores — first_full_v1 | 112.464 MB | 405.454 MB | 517.918 MB | standard_student_download; measured |
| MD&A narrative and scores — pilot_student_v1 | 0.505 MB | 1.806 MB | 2.311 MB | standard_student_download; measured |
| SEC correspondence text — pilot_v1 | 0.068 MB | 0.175 MB | 0.243 MB | standard_student_download; measured |
| SEC correspondence text — full corpus (not yet produced) | not available | not available | not available | standard_student_download; planned |

Raw/company/sector representations overlap; there is **no unique-content grand total**. Local raw staging and processed audits are physical storage, not extra logical datasets. Student pilot/full derivatives can overlap by accession; do not add them as independent content.

For sector ZIPs, first-level extraction creates company ZIPs plus sector metadata. Final expansion uses local company ZIP directories where member names/sizes and recorded SHA identities agree. This is metadata agreement, not a new full payload validation. Retaining outer archives, nested company archives and extracted filings costs outer ZIP + first-level extraction + inner expanded contents. ZIP+final alone omits retained nested archives. Unknown recursive expansion remains blank.

Raw archives are available on request. Sharing links are blank. Standard student downloads are only actual compact packages; full correspondence is planned until produced. Growing/active outputs are provisional.

## Sector breakdown

| Sector | Companies | Parts | Download GB | Final expansion GB |
| --- | ---: | ---: | ---: | ---: |
| Accommodation and Food Services | 44 | 1 | 0.766 | 3.836 |
| Administrative and Support and Waste Management and Remediation Services | 42 | 1 | 0.692 | 3.817 |
| Agriculture, Forestry, Fishing and Hunting | 7 | 1 | 0.102 | 0.637 |
| Arts, Entertainment, and Recreation | 20 | 1 | 0.273 | 1.587 |
| Construction | 38 | 1 | 0.630 | 3.157 |
| Educational Services | 12 | 1 | 0.137 | 0.887 |
| Finance and Insurance | 458 | 8 | 9.079 | 74.381 |
| Health Care and Social Assistance | 43 | 1 | 0.663 | 3.695 |
| Information | 267 | 2 | 4.007 | 20.899 |
| Manufacturing | 810 | 7 | 13.289 | 70.363 |
| Mining, Quarrying, and Oil and Gas Extraction | 90 | 1 | 2.720 | 10.127 |
| Other Services (except Public Administration) | 6 | 1 | 0.124 | 0.626 |
| Professional, Scientific, and Technical Services | 121 | 1 | 2.076 | 9.304 |
| Real Estate and Rental and Leasing | 140 | 2 | 3.271 | 17.159 |
| Retail Trade | 83 | 1 | 0.922 | 5.479 |
| Transportation and Warehousing | 69 | 1 | 1.121 | 6.253 |
| Utilities | 63 | 1 | 1.659 | 10.565 |
| Wholesale Trade | 51 | 1 | 0.621 | 3.792 |

## Physical staging/audit representations (not extra unique downloads)

| Representation | Local bytes | Decimal size |
| --- | ---: | ---: |
| Complete EDGAR raw staging | 246642492151 | 246.642 GB |
| MDA central processed/audit artifacts | 125284154963 | 125.284 GB |
| MDA run checkpoint/summary first_full_v1 | 58936517 | 58.937 MB |
| Expanded student package first_full_v1 | 405454084 | 405.454 MB |
| MDA run checkpoint/summary pilot_student_v1 | 278625 | 0.279 MB |
| Expanded student package pilot_student_v1 | 1806026 | 1.806 MB |
| CORRESPONDENCE central processed/audit artifacts | 258126 | 0.258 MB |
| CORRESPONDENCE run checkpoint/summary pilot_v1 | 11001499 | 11.001 MB |
| Expanded student package pilot_v1 | 174611 | 0.175 MB |
| EDGAR HTTP metadata/cache | 362647839 | 362.648 MB |
| EDGAR acquisition manifests | 51123400 | 51.123 MB |
| Earlier downloader validation artifacts | 1026570913 | 1.027 GB |
| MD&A legacy pilot summary/audit metadata | 167019 | 0.167 MB |
| Earlier EDGAR feasibility pilot representations | 1472500005 | 1.473 GB |
| Correspondence pilot PDF review renderings | 452672 | 0.453 MB |

## Known source/content overlaps

| Dataset A | Dataset B | Shared source accessions |
| --- | --- | ---: |
| correspondence_student_pilot_v1 | edgar_company_archives | 29 |
| correspondence_student_pilot_v1 | edgar_raw | 29 |
| correspondence_student_pilot_v1 | edgar_sector_archives | 29 |
| edgar_company_archives | edgar_raw | 20157 |
| edgar_company_archives | edgar_sector_archives | 20157 |
| edgar_company_archives | mda_student_first_full_v1 | 6618 |
| edgar_company_archives | mda_student_pilot_student_v1 | 30 |
| edgar_raw | edgar_sector_archives | 20157 |
| edgar_raw | mda_student_first_full_v1 | 6624 |
| edgar_raw | mda_student_pilot_student_v1 | 30 |
| edgar_sector_archives | mda_student_first_full_v1 | 6618 |
| edgar_sector_archives | mda_student_pilot_student_v1 | 30 |
| mda_student_first_full_v1 | mda_student_pilot_student_v1 | 30 |

These are identity-backed source intersections, not claims of byte-identical derived text. Raw archive alternatives have the same recorded company-archive identities; student extracts retain source accessions but transform the content.

Read/metadata issues: 0. See inventory_diagnostics.json; ZIP directory readability does not certify CRC integrity.

Commands from repository root: `python -m dataset_inventory refresh`; paste genuine sharing URLs into `dataset_inventory/data/output/download_catalog_template.csv`, preserving dataset_id and package_path; then `python -m dataset_inventory render`. Render flags duplicate/unmatched IDs and package-name conflicts. Optional additional datasets must be explicitly listed in config/datasets.json; unrelated repositories are not scanned.
