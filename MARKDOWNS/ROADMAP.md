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

Production değerlendirme raporu **tamamlandı**, stabil v1.0 sertifikasyonu **bekliyor**: fiziksel mobil/gamepad, kötü ağ/streaming, death-reset-reconnect matrisi, uzun soak/toplam engine-memory-network profili, Roblox type-aware analiz ve farklı kullanıcı rigleri. Başlangıçta istenen production hedefi bu testler yapılmadan tamamlandı sayılmaz. docs/READINESS.md koşulları ayrıntılandırır. Ses/damage/prediction/clutch gibi uygulanmayan özellikler kesinleşmiş yeni kapsam değildir.

Bağımlılık: sözleşme → saf hesaplar → rig/runtime → örnekler → Studio testleri → hata düzeltme → teslim. Dış model lisansı kit lisansından ayrı; yeniden dağıtım doğrulanmadan modele MIT etiketi uygulanmaz.

## İkinci geliştirme kapsamı — 2026-10-29

Kullanıcı tarafından istenenler: otomatik devrilme düzeltme; varsayılan VehicleSeat HUD yerine hız/vites/RPM ve tuş ipuçları olan gizlenebilir özel HUD; mobil gaz/fren/direksiyon/el freni/çıkış; import aracının sallanmasının giderilmesi; gerçek A-Chassis Toolbox araçlarında kolay dönüşüm ve birkaç araçlık uyumluluk matrisi; araç içindeki açıklamalı Tune'dan temel fizik/güç/kontrol ayarları; roblox-vfx becerisiyle sürüş efektleri.

| İş | Durum | Doğrulama |
|---|---|---|
| Sallanma teşhisi ve çözümü | tamamlandı | aynı sahnede önce/sonra + beş rig jitter eşiği geçti |
| Otomatik kurtarma | tamamlandı | inverted/airborne/upright/blocked/occupied senaryoları geçti |
| HUD ve mobil kontrol | tamamlandı | yuvarlak tasarım kullanıcı tarafından onaylandı; cihaz yerleşimleri ve input geçti |
| Genişletilmiş açıklamalı Tune | tamamlandı | tutorial/şema/Power-MaxSpeed-Mass/tuş düzeni; P remap doğrulandı |
| A-Chassis dönüşüm aracı | tamamlandı | Edit-only geometry clone, kaynak korunur, güvenlik fixture geçti |
| Çok araç uyumluluk | tamamlandı | üç gerçek A-Chassis car; Doctor/drive/jitter/cleanup geçti |
| Sürüş VFX | tamamlandı | community MCP, özel texture, dört hold + canlı client kontrolü |
| Paket/belge/CI teslimi | tamamlandı | yerel dosya ve paketler doğrulandı; kaynak2d25103, remote Validate40903141125 success |

Başlangıç titreşim ölçümü: 120 PostSimulation örneğinde prototip RMS vy 0.202, RMS açısal hız 0; import RMS vy 0.755, RMS açısal hız 1.970 rad/s, tepe 3.327. Bu kayıt çözüm sonucu değildir.

0.2 detay/kanıt: docs/COMPATIBILITY.md, docs/HUD.md, docs/VFX.md ve docs/TESTING.md güncel bölümü. Portre simulator kontrolü tamamlandı; fiziksel cihaz ve modern A-Chassis1.7.2 model testi hâlâ açık. Stabil v1.0 koşulları korunur.

## GUI görünmeme düzeltmesi

Uygulama ve Studio doğrulaması tamamlandı: eksik ana sahne aktarımı, korumalı container ve açık editör buffer hataları düzeltildi. Ana sahnede giriş/H/çıkış/ikinci araç/respawn ve75 test geçti. Paketler yenilendi; hotfix50b3fc0 ve Validate40908822445 success.

## 0.3 kullanıcı kapsamı

Sürüyor: P ile el freninden ayrı kalıcı park modu; gerçek araçların içindeki Tune kopyalarında bütün desteklenen alanlar ve kapsamlı Türkçe rehber; tek lisanslı ikon setinden görsel mobil gaz/fren/el freni/park/çıkış/direksiyon; viraj yatışına karşı ayarlanabilir denge ve ölçümlü önce/sonra testi. Ana Studio hedefi korunacak.


0.3 uygulama/doğrulama tamamlandı: ayrı park (P/W/P/E, spawn/exit ve8° eğim);49 alanlı rehber gerçek iki ana araç ve4 uyumluluk kaynağının içinde; kullanıcı onaylı9 ikonlu dokunmatik kontrol; ayarlanabilir viraj dengesi. Import tepe yatış8.409→0.457°, prototip10.329→0.879°; dört import jitter geçer.90 Studio/83 headless/56 compile. Telefon7/13 ve iPadA16 landscape giriş/yerleşim kontrolü geçti. Son aşama: GitHub push/CI ve teslim kaydı sürüyor. Fiziksel multitouch/0.3 iki-client park/adverse-network/modern1.7.2/stabil1.0 kapıları önceki açık kapsam olarak korunur.

0.3 GitHub teslimi tamamlandı: kaynak098e2a527dadbab933608f24e01fa72c2d525f14, Validate40927928835 completed/success. Son devir notu ayrı docs commit'idir; mevcut0.3 kullanıcı işlerinde bekleyen uygulama yok. Stabil1.0 açık kapıları yukarıda korunur.
