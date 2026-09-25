# Wallet localization baseline repair

The audit initially failed on four absent keys in 24 locales. Only those 96 entries were added. Total value copies each locale’s existing `g_portfolio_total` exactly. Price, recipient address and sender address are short generic translations, with no AA-specific terminology. The pseudo-locale uses the existing `pseudo_transform` function for the three new translations.

Generated Dart files were produced by `dart run intl_utils:generate`; none were edited by hand. No localization baseline or allowlist was changed.

| Locale | Total value (reused) | Price | Recipient address | Sender address |
| --- | --- | --- | --- | --- |
| ar | القيمة الإجمالية | السعر | عنوان المستلم | عنوان المرسل |
| bn | মোট মান | মূল্য | প্রাপকের ঠিকানা | প্রেরকের ঠিকানা |
| cs | Celková hodnota | Cena | Adresa příjemce | Adresa odesílatele |
| de | Gesamtwert | Preis | Empfängeradresse | Absenderadresse |
| es_ES | Valor total | Precio | Dirección del destinatario | Dirección del remitente |
| fr | Valeur totale | Prix | Adresse du destinataire | Adresse de l’expéditeur |
| hi | कुल मूल्य | कीमत | प्राप्तकर्ता का पता | प्रेषक का पता |
| id | Nilai Total | Harga | Alamat penerima | Alamat pengirim |
| it | Valore totale | Prezzo | Indirizzo del destinatario | Indirizzo del mittente |
| ja | 合計値 | 価格 | 送信先アドレス | 送信元アドレス |
| ko | 총 가치 | 가격 | 받는 주소 | 보내는 주소 |
| mr | एकूण मूल्य | किंमत | प्राप्तकर्त्याचा पत्ता | पाठवणाऱ्याचा पत्ता |
| pl | Całkowita wartość | Cena | Adres odbiorcy | Adres nadawcy |
| pt | Valor total | Preço | Endereço do destinatário | Endereço do remetente |
| pt_BR | Valor total | Preço | Endereço do destinatário | Endereço do remetente |
| qps | [# Ťöťàĺ Ṽàĺüé ~~~~~#] | [# Ƥŗìçé ~~#] | [# Ťö àððŗéšš ~~~~~#] | [# Ƒŗöṁ àððŗéšš ~~~~~~#] |
| ru | Общая стоимость | Цена | Адрес получателя | Адрес отправителя |
| sw | Jumla ya Thamani | Bei | Anwani ya mpokeaji | Anwani ya mtumaji |
| ta | மொத்த மதிப்பு | விலை | பெறுநரின் முகவரி | அனுப்புநரின் முகவரி |
| te | మొత్తం విలువ | ధర | గ్రహీత చిరునామా | పంపినవారి చిరునామా |
| tr | Toplam Değer | Fiyat | Alıcı adresi | Gönderen adresi |
| uk | Загальна вартість | Ціна | Адреса одержувача | Адреса відправника |
| ur | کل قدر | قیمت | وصول کنندہ کا پتہ | بھیجنے والے کا پتہ |
| vi | Tổng giá trị | Giá | Địa chỉ người nhận | Địa chỉ người gửi |

Evidence: `511` exact key/value JSON; `512` generator; `518` wallet audit passes; `514` 39 Python tests; `515` format; `516` analyzer (0 errors, 0 warnings); `517` 56 localization/wallet tests. `513` full audit still fails on the separate Chat translation baseline, detailed in `519`/`521`.

The root coverage run predates this labels-only repair. It is retained at its recorded verification point; no new behavior test or broad coverage expansion was added. Final Android/iOS incremental builds run after generation (`430`/`431`).
