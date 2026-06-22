#!/usr/bin/env wolframscript
(* Sends a completion notification for the BUTTERFLY 120-word incorporation. *)

Print["CloudConnected: ", TrueQ[$CloudConnected]];

body = "BUTTERFLY 120-word stimulus set incorporated.\n\n" <>
  "- Parsed 120 words from current-words/main.pdf, grouped into 4 conditions of 30:\n" <>
  "    RH (items 1-30, triggers 210/201), RL (31-60, 220/202),\n" <>
  "    NH (61-90, 230/203), NL (91-120, 240/204).\n" <>
  "- Built master current_list.csv (120 rows) and ListA/B/C/D.mat.\n" <>
  "- Each list contains all 120 items in an independent randomized order\n" <>
  "    (fixed seeds 1-4 for reproducibility).\n" <>
  "- Copied all 120 pictures into images/ (movement.png converted to .jpg).\n" <>
  "- Audio: the 20 existing .wav files are cycled across all 120 items as\n" <>
  "    placeholders, so trials run end-to-end. Real per-word recordings still\n" <>
  "    need to replace these.\n\n" <>
  "Verification: every referenced image and audio file exists; itemTriggers\n" <>
  "form a clean permutation of 1-120 in every list; no trigger mismatches.\n";

result = SendMail[<|
  "To" -> "cscooley3@gmail.com",
  "Subject" -> "BUTTERFLY: 120-word stimulus set incorporated",
  "Body" -> body
|>];

Print["ResultHead: ", Head[result]];
Print["ResultFull: ", ToString[result]];
