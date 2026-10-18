# InvoiceMaker

Simple invoicing for German self-employed people and small businesses (Kleinunternehmer and VAT-registered).
Write invoices that meet the German requirements, track expenses and see your yearly figures –
in English or German, right in your browser. **No account, no server: your data stays on your device.**

## Features

- **Invoices that meet § 14 UStG** – your tax number or VAT ID, sequential invoice numbers, service date,
  net/VAT/gross per VAT rate (19 %, 7 %, 0 %). Preview and download as PDF.
- **Small business mode (§ 19 UStG)** – no VAT on invoices, with the required note added automatically.
- **Issued invoices can't be changed** – like the law requires; you cancel an invoice instead of deleting it.
  Drafts can be edited or deleted freely.
- **Paid / unpaid tracking** – see which invoices are still open.
- **Clients** – save clients once and pick them when you write an invoice (on Android also from your contacts).
- **Expenses** – record business expenses by category (goods, tools, vehicle & travel, office & phone, ...).
- **Yearly overview (EÜR)** – income, expenses (net) and profit for the year at a glance.
- **Backup & restore** – download all your data as one file and restore it on any device.
- **English and German**.

## Privacy

Everything is stored locally in your browser (or on your phone). Nothing is sent to a server, and the PDF viewer
(pdf.js) is bundled with the app, so no third-party scripts are loaded. Because data only lives on your device,
use **Download backup** regularly.

## Building

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install).

```bash
flutter pub get
flutter run -d chrome          # or a connected Android device
flutter build web --release    # static site in build/web
```

To host it on Cloudflare, build the web version and run `npx wrangler deploy` (see `wrangler.jsonc`).
Any static web host works too.

> InvoiceMaker helps you create correct invoices, but it is not tax advice. Check with your tax advisor if unsure.

## License

MIT – see [LICENSE](LICENSE). The bundled pdf.js (`web/pdfjs/`) is © Mozilla Foundation, Apache-2.0.
