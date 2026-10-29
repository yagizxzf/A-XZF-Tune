# Yol haritası

Kullanıcının kapsamı: A-XZF-Tune adında sıfırdan A-Chassis alternatifi, verilen GitHub deposu, modüler/performanslı/kolay kullanım, prototip araç ve dış kaynaklı parçalı model, kapsamlı test ve dokümantasyon; değerlendirmeye açık production-ready açık kaynak hedefi.

| Aşama | Durum | Tamamlanma ölçütü |
|---|---|---|
| Kaynak ve Studio incelemesi | tamamlandı | boş repo, mevcut place, upstream release doğrulandı |
| Mimari/deney/rig sözleşmesi | sürüyor | yetki sınırı, formüller, eşikler, bağımlılıklar yazılı |
| Şema ve saf fizik hesapları | bekliyor | doğrulama ve sınır testleri |
| Rig adapter/doctor | bekliyor | parçalı model, hatalı model reddi, idempotent cleanup |
| Sunucu fiziği, sürüş, ağ | bekliyor | süspansiyon, lastik tutuşu, güç aktarma, fren, direksiyon, güvenli giriş |
| Girdi ve gözlem araçları | bekliyor | klavye/gamepad/touch tasarımı, telemetri, anlaşılır hata |
| Örnek araç/pist/paketleme | bekliyor | çalıştırılabilir kaynak, yeniden üretilebilir Studio dosyaları |
| Dış araç tedarik/adapter/test | bekliyor | kaynak/provenance, karantina, parçalı modelde Play kanıtı |
| Birim/entegrasyon/sürüş testleri | bekliyor | gerçek sonuçlar, failure paths ve temizlik |
| Açık kaynak belgeleri/GitHub teslimi | bekliyor | MIT, API, kurulum, migration, katkı, güvenlik, test raporu |
| Production değerlendirme | bekliyor | sonuçlara göre kalan release kapıları açıkça listeli; ölçülmeyeni tamamlandı sayma |

## 2026-10-29 uygulama durumu

Başlangıç planının devamı: mimari/deney sözleşmesi, saf hesaplar, şema, rig/Doctor/adapter, sunucu fizik/ağ, native girdi/telemetri, örnekler, Python paketleme, dış model tedarik/ayıklama, birim/entegrasyon/sürüş/handling/iki istemci testleri ve belgeler **tamamlandı**. Kanıt: docs/TESTING.md ve evidence/studio-results.json. GitHub teslimi **sürüyor**; push sonrası HANDOVER güncellenecek.

Production değerlendirme raporu **tamamlandı**, stabil v1.0 sertifikasyonu **bekliyor**: fiziksel mobil/gamepad, portre, kötü ağ/streaming, death-reset-reconnect matrisi, uzun soak/toplam engine-memory-network profili, Roblox type-aware analiz ve farklı kullanıcı rigleri. Başlangıçta istenen production hedefi bu testler yapılmadan tamamlandı sayılmaz. docs/READINESS.md koşulları ayrıntılandırır. Ses/damage/prediction/clutch gibi uygulanmayan özellikler kesinleşmiş yeni kapsam değildir.

Bağımlılık: sözleşme → saf hesaplar → rig/runtime → örnekler → Studio testleri → hata düzeltme → teslim. Dış model lisansı kit lisansından ayrı; yeniden dağıtım doğrulanmadan modele MIT etiketi uygulanmaz.
