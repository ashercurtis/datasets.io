# Student MD&A narrative and scores

Run: first_full_v1. Text description: **MD&A narrative—tables excluded**.
One row per eligible selected original 10-K, including failed/uncertain cases. Only accepted rows have narrative paths and text hashes. CIK is the actual filing registrant, not an inferred fiscal-year identifier. There is no Compustat fyear.

CSV files are UTF-8 without BOM, comma-delimited, with quoted/escaped fields as needed. In Alteryx choose UTF-8 and import CIK/accession/ticker as strings to preserve leading zeros. Narrative paths are relative to this package root.

Text bytes are copied without summaries, metadata prefixes or reformatting from the explicit central sentiment input. Paragraphs and punctuation remain. The numbered Item 7 heading is excluded just as in the existing scoring pipeline. Prose in layout tables is retained under the structural policy; genuine numeric tables are excluded. Original filings, table fragments, readable HTML, detailed word/sentence audits and diagnostics stay centrally and are not part of this compact package.

Readability applies an extra prose selection: short headings/bullet fragments and recognized page furniture are excluded; prose needs at least five alphabetic runs and punctuation, and retained Syntok sentences need three readability words. Readability compounds/apostrophes are single words while sentiment uses alphabetic runs. Syllables use LM counts, bundled CMUdict and a recorded minimum-one fallback. Thus readability W differs from sentiment n_word_tokens. The exported full narrative remains unchanged; readability does not use every word in it.

Six LM categories use active flags >0, including negative removal-marker handling. Counts repeat exact matches without stemming, stopwords or automatic negation adjustment; categories can overlap. The fixed Loughran-McDonald_MasterDictionary_1993-2025.csv dictionary is applied across periods (SHA-256 e2d1328682bab7d2187684fb9f5420bb730401c9eefc00daf835edd203f4859d). This is not historical dictionary reconstruction or a reconstructed historical investable universe. Shares are fractions; net tone can be negative; undefined denominators are blank.

gunning_fog_simplified counts all >=3-syllable words without exclusions for names/compounds/suffixes. Higher Fog/grade means harder estimated reading; higher Flesch Reading Ease means easier reading. Flesch is not clamped. These are readability proxies, not complete business complexity measures. Uncertainty extraction status is separate from LM uncertainty counts.

Asher Curtis reported acceptance of inspected pilot narrative samples. No file count, accession labels or approval time were supplied. That review does not validate every future filing or all table renderings. Automated warnings and withholding remain active. See data_dictionary.csv and central reports for conventions and limitations.
