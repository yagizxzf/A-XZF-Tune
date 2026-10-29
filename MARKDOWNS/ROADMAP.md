# Yol haritası

Kullanıcının kapsamı: A-XZF-Tune adında sıfırdan A-Chassis alternatifi, verilen GitHub deposu, modüler/performanslı/kolay kullanım, prototip araç ve dış kaynaklı parçalı model, kapsamlı test ve dokümantasyon; değerlendirmeye açık production-ready açık kaynak hedefi.

| Aşama | Durum | Tamamlanma ölçütü |
|---|---|---|
| Kaynak ve Studio incelemesi | tamamlandı | boş repo, mevcut place, upstream release doğrulandı |
| Mimari/deney/rig sözleşmesi | tamamlandı | yetki sınırı, formüller, eşikler, bağımlılıklar yazılı |
| Şema ve saf fizik hesapları | tamamlandı | doğrulama ve sınır testleri geçti |
| Rig adapter/doctor | tamamlandı | parçalı model, hatalı model reddi, idempotent cleanup |
| Sunucu fiziği, sürüş, ağ | tamamlandı | süspansiyon, lastik tutuşu, güç aktarma, fren, direksiyon, güvenli giriş |
| Girdi ve gözlem araçları | tamamlandı | klavye/gamepad/touch uygulaması; klavye ve touch simülatör doğrulaması; fiziksel gamepad açık |
| Örnek araç/pist/paketleme | tamamlandı | çalıştırılabilir kaynak, yeni Studio'da açılan dosyalar |
| Dış araç tedarik/adapter/test | tamamlandı | kaynak/provenance, karantina, 47 parçalı modelde Play kanıtı |
| Birim/entegrasyon/sürüş testleri | tamamlandı | belirlenen test kapsamı geçti; genişletilmiş adoption matrisi aşağıda açık |
| Açık kaynak belgeleri/GitHub teslimi | tamamlandı | MIT, API, kurulum, migration, katkı, güvenlik, test raporu, başarılı remote CI |
| Production değerlendirme | rapor tamamlandı; v1.0 bekliyor | kalan release kapıları docs/READINESS.md içinde |

## 2026-10-29 uygulama durumu

Başlangıç planının devamı: yukarıdaki uygulama/test/belge aşamaları tamamlandı. Kanıt: docs/TESTING.md ve evidence/studio-results.json. 2026-10-29T15:39:07+03:00 itibarıyla GitHub main f870ffc kaynak sürümü ve remote Validate CI başarılı. Bu teslim release candidate değerlendirmesidir.

Production değerlendirme raporu **tamamlandı**, stabil v1.0 sertifikasyonu **bekliyor**: fiziksel mobil/gamepad, portre, kötü ağ/streaming, death-reset-reconnect matrisi, uzun soak/toplam engine-memory-network profili, Roblox type-aware analiz ve farklı kullanıcı rigleri. Başlangıçta istenen production hedefi bu testler yapılmadan tamamlandı sayılmaz. docs/READINESS.md koşulları ayrıntılandırır. Ses/damage/prediction/clutch gibi uygulanmayan özellikler kesinleşmiş yeni kapsam değildir.

Bağımlılık: sözleşme → saf hesaplar → rig/runtime → örnekler → Studio testleri → hata düzeltme → teslim. Dış model lisansı kit lisansından ayrı; yeniden dağıtım doğrulanmadan modele MIT etiketi uygulanmaz.
