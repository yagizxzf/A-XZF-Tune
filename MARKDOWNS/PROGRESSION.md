# Geliştirme günlüğü

## 2026-10-29T14:57:53+03:00
- Boş hedef depo clone edildi, gerçek kök belirlendi. Önceden proje belgeleri veya kaynak yok.
- Studio MCP tek A-XZF-Tune place'ine bağlı; edit durumu ve servisler okundu. Henüz mutasyon yapılmadı.
- A-Chassis README, metadata ve v1.7.2-stable release notları okundu. Kod kopyalanmadı.
- gh kimlik doğrulaması yok; GitHub connector push/admin yetkili. rojo shim kurulmuş ama sürüm yapılandırılmamış. Bunlar başarılı build değildir.
- Kullanıcı kapsamı ROADMAP'e aktarıldı; uygulama/testler bekliyor.

## 2026-10-29T15:36:37+03:00
- Kullanıcının ek talimatı: tüm geliştirme Life IS Roblox/A-XZF-Tune içinde. Kaynaklar, belgeler, build, testler ve araçlar bu kökte tutuldu.
- Bağımsız modüler Luau kit geliştirildi: Tune/Math/InputGuard/Powertrain/Presets, Doctor/Adapter/Rig/Vehicle/Fleet, Driver ve Bootstrap. Upstream kodu/model mekaniği kopyalanmadı.
- Özgün parçalı araç/pist ve Creator Store 14215126016 için geometry-only adapter eklendi. 75 parçalı kaynak karantinada incelendi, 14 yabancı kod konteyneri hiç çalıştırılmadan dışlandı. Son araç 47 BasePart/45 MeshPart. Erişilemeyen kaplamalar çıkarıldı. Art yeniden dağıtım hakkı doğrulanmadığı için Git'e dahil edilmedi; yerel art-inclusive sahne .gitignore altında üretildi.
- İzole spring deneyi 301 örnek/5 saniye geçti; düzenek kaldırıldı. 65 Studio testi (ilk koşu 64/65; WeldConstraint hatası düzeltilip 65/65), 58 headless sözleşme testi, 28 Luau compile ve deterministik paket kontrolü geçti.
- İki araç sürüş/fren/direksiyon/watchdog/rebind geçti. Handling: airborne thrust 0, Grip karşılaştırması, el freni/geri/8 derece eğim geçti. 12 araç Lua solve ort. 0.739 ms, p95 1.070 ms; toplam engine/network perf iddiası yok.
- İki gerçek istemci StudioTestService testi geçti: sürücü dışı kontrol/bozuk/replay reddi, doğru sürüş, server ownership ve exit. Telefon/tablet simülasyonunda düğme overlap düzeltildi; 64 px safe area, Exit/native control restoration geçti. Textbox focus hareketi engelledi; focus sonrası gaz tekrar çalıştı.
- Python .rbxmx/.rbxlx paketleme, local art export ve pinned/hash-verified Luau CI eklendi. Bağımsız demo yeni Studio'da açıldı ve 65 test geçti. Yerel mesh export ilk denemede InitialSize eksikliği tespit edilip düzeltildi, yeniden açılan mesh size orijinalle eşleşti.
- Kurulum/model/API/tuning/migration/assets/testing/readiness, MIT, katkı/güvenlik/changelog yazıldı. Release candidate 0.1.0; stabil production gates açık. Play durduruldu, cihaz simülatörü defaulta alındı. GitHub teslimi sırada; henüz push/CI sonucu bu kayıtta başarılı sayılmıyor.

## 2026-10-29T15:39:07+03:00
- GitHub main'e `f870ffcabee823d985be5b95d7cb5aaecc0d0796` kaynak sürümü gönderildi. Connector create_commit taşıma hatası sonrası mevcut Git credential manager ile normal commit/push başarılı oldu; zorla push yok.
- Remote Validate CI run 40874968917 completed/success; yerel 28 compile / 58 headless / deterministik build sonuçlarıyla uyumlu.
- .gitattributes LF ile Windows/Linux paket byte tutarlılığı korundu. Studio lock dosyaları index'ten çıkarılıp ignore edildi; gerçek kaynaklar korunur. Yerel sanat sahnesi/geometri dump'ı Git dışında.
- HANDOVER/ROADMAP durumları güncellendi. Stabil v1.0 için kalan adoption testleri açık; bu sonuçlar tamamlanmış gibi işaretlenmedi.
