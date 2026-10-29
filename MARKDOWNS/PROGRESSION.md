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

## 2026-10-29T18:16:00+03:00
- İkinci kullanıcı kapsamı uygulandı: otomatik düzeltme, kullanıcının yuvarlak sürüm onayı sonrası HUD/mobil düğmeler, gizlenen tuş yardımı, per-car Tune tutorial/güç/hız/kütle/tuşlar ve istemci VFX.
- İthal araç jitter'ı ortak pre-step temas + implicit coupled spring ve sürekli VectorForce/Torque ile düzeltildi. Aynı sahne120 örnek: import açısal RMS1.96966→0.02970, vy0.75510→0.00000292, yükseklik aralığı0.08276→0. Üç yeni migration ve prototip/ilk import180 örnek eşiklerini geçti.
- Creator Store4529389736/5933886177/9857510493 inert ServerStorage'da incelendi; legacy kod yürütülmedi. Geometry-only converter ve seçimden tek çağrı eklendi. Çıktılar118/87/77 parça, sıfır legacy kod, Doctor/sürüş/fren/direksiyon/timeout/cleanup/rebind geçti. Kaynaklar korundu; modern1.7.2 araç denenmedi.
- 75/75 Studio,68 headless,48 compile, deterministik paket kontrolü geçti. Recovery ters/dik/havada/engel/engel kalkması; dolu koltuk; Fleet lifecycle ve iki gerçek istemci güvenlik regresyonu geçti. Yeni12-car Lua mean0.781/p951.109/max3.240ms; toplam engine profili değildir.
- Bir lifecycle hatası yakalandı: parent sinyalinde fizik montajı hazır olmadan sahiplik verilemiyordu. Spawn bind bir Heartbeat ertelendi ve concurrent bind/cancel korundu; ilgili test tekrar geçti.
- iPhone7/13 yatay, iPhone13 dikey, iPad6 yatay simulator yerleşimleri kontrol edildi. GO/PARK/KEYS/EXIT ve Tune'dan Handbrake=P çalıştı. Düğme dışına sürükleyip bırakmada throttle1→0 doğrulandı. Native seat HUD kaldırma/TouchGui gizleme/çıkışta geri getirme ve device-switch düzeltildi.
- roblox-vfx kullanıldı: özel NumPy dokuları,0.05/0.20/0.50/0.90 hold yakın/sürücü kontrolleri, iki settled upload, uploaded texture yeniden kontrol ve canlı client burst. Server Workspace emitter0; preview leftovers boş. MIT araç lisansları/NOTICE korundu.
- Test düzeneği önce zeminsiz dış koordinat ve kısa pist yüzünden başarısız oldu; recovery için kendi zemini, drive için engine limitinin altındaki2000-stud lane eklendi. Eşikler değiştirilmeden yeniden test edildi.
- Native local scene export sorunları (NetAsset XML, binary Service flags, yeni PhysicalProperties) teşhis edildi. Binary geometri ve explicit Tune.Mass ile doğru boyut/kütle korundu. Son dosya yeniden açıldı:5 araç bağlı/dik/kararlı,45 MeshPart31 union ve75 test doğrulandı. Başarısız ara helper pencereler temizlendi; mevcut kullanıcı Studio pencereleri korundu.
- build/A-XZF-CompatibilityDemo.rbxl ve native dış-art paketi Git dışında; public paket yalnızca özgün prototip/kod içerir. Dökümantasyon/kanıtlar güncellendi. Bu kayıtta yeni push/remote CI henüz tamamlandı sayılmıyor.

## 2026-10-29T18:32:08+03:00
- Son iptal-yeniden bağlama koruması için geciken Tune fixture ve regresyon eklendi: pendingCancelRebind geçti. Geçersiz eski işlem yeni işlemin token bilgisini silmiyor. Güncel kaynak49 Luau;68 headless,75 Studio ve tüm Fleet senaryoları geçti. Bu ek test fizik çözümünü değiştirmedi. Play durduruldu.

## 2026-10-29T18:35:33+03:00
- Kaynak07db86c GitHub main'e gönderildi. İlk remote Validate40902578751: compile49/headless68 geçti, paket byte eşitliği başarısız. Sebep Windows Path sıralamasının case-insensitive, Linux sıralamasının case-sensitive olması; VFXService/Vehicle kayıt sırası farklıydı. Build dosya adı string'iyle açık sıralandı, paketler yeniden üretildi, yerel kontroller geçti. Remote düzeltme doğrulaması sırada. Önceki başarısız CI başarılı olarak raporlanmıyor.
