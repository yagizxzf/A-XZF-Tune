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

## 2026-10-29T18:39:23+03:00
- 2d251034caf13832b20fa2d3f70c75ad1ac20aaf main'e gönderildi. GitHub Validate40903141125 completed/success: https://github.com/yagizxzf/A-XZF-Tune/actions/runs/40903141125.49 compile/68 headless/deterministik paket kontrolü remote ortamda geçti.75 Studio ve son pendingCancelRebind sonuçları kanıt dosyalarında.
- İstenen0.2 geliştirme teslimi tamamlandı; HANDOVER/ROADMAP güncellendi. Yerel gerçek araçlı .rbxl Git dışında; public kaynak/paket/docs GitHub'da. Stabil v1.0 adoption koşulları açık tutuldu.

## 2026-10-29T19:09:42+03:00
- Kullanıcı GUI görünmüyor bildirdi. Görünür asıl A-XZF-Tune Studio (place72435697524161) incelendi: UI klasörü yok, eski Driver5749 karakter ve iki satırlık Bootstrap vardı. Ayrı demo cold-client koltuk testi GUI açtı; önceki teslimin ana sahne aktarımı eksik kalmıştı.
- Komut çubuğu installer mevcut StarterPlayerScripts.Parent alanını tekrar yazınca duruyordu. Yalnızca yeni klasörlerde Parent ayarlayacak şekilde düzeltildi. Source ataması açık Fleet editörünü eşitlemiyordu (Source6061/editor4631); ScriptEditorService.UpdateSourceAsync ile açık editör de güncelleniyor.
- Default Fleet.start cockpit şablonunu kendisi hazırlıyor; eski/manual Bootstrap da GUI başlatabiliyor. Driver/UI bağımlılıkları replication sırasını bekliyor; eksik UI/template15 saniyede açıklamalı hata veriyor. Tasarım değişmedi; yeni görsel onayı gerekmedi.
- Güncel kaynaklar gerçek ana Studio'ya uygulandı. Community köprüsü bu eski pencerede yüklü olmadığından mevcut built-in Studio bağlantısı kullanıldı; hiçbir kullanıcı penceresi kapatılmadı. R3dTuxedo ve araç geometrisi korundu; yerel kaynak yedeği ignore edildi.
- Ana sahnede75/75 Studio; prototipte GUI açık, bir kopya; H gizleme; E çıkışta HUD kapanması; import araca tekrar girişte açılması; ölüm/respawn sonrası tek GUI ve tekrar açılma geçti. Kanıt evidence/gui-hotfix-*.json. İki test Play oturumu durduruldu.49 compile/68 headless/deterministik paket kontrolleri geçti; .rbxl demo yenilendi. Yeni push/CI bu kayıtta henüz tamamlandı sayılmıyor.

## 2026-10-29T19:12:06+03:00
- GUI hotfix50b3fc0220cf0db5e3cdf58342e4017c822d9955 main'e gönderildi. Remote Validate40908822445 completed/success: https://github.com/yagizxzf/A-XZF-Tune/actions/runs/40908822445. Ana Studio GUI giriş/H/E/ikinci araç/respawn ve75 test kanıtları,49 compile/68 headless/deterministik paket sonucu ile birlikte doğrulandı.
- Ana Studio ve test demosu Edit bırakıldı. Gerçek asıl proje artık güncel; önceki yalnız-demo teslim bilgisi HANDOVER'da düzeltildi. Canlı publish yapılmadı.

## 2026-10-29T21:07:36+03:00
- Kullanıcının0.3 dört isteği uygulandı: P ile ayrı kalıcı park, gerçek araçlarda49 alanlı Türkçe Tune/tutorial, onay sonrası9 Lucide ikonlu mobil kontrol, ayarlanabilir viraj dengesi. Önceki rehberin gerçek main prototype'da bulunmadığı ve importta yalnızca3 ayar olduğu açıkça tespit edilip düzeltildi; eski başarı kayıtları değiştirilmedi.
- Main iki araç ve dört compatibility source Tune güncellendi; import Radius1.5/FWD/TorqueScale5 korundu. TuneEditor Edit-only, açık overrides ve SES editor senkronu; custom AWD/Power1.7/Radius1.8/ParkO/curve doğrulandı.
- Aynı yolcu temsili/55-90stud/s/iki yön karşılaştırması: import tepe8.409→0.457°, prototip10.329→0.879°. Dört import jitter eşiklerini geçti; airborne/Grip/handbrake/reverse/slope regresyonu geçti. Park P/W/P/E ve spawn/exitopsiyonları gerçek insanla geçti. Son8° slope0.0589stud/s (<0.1); velocity-only fren creep'i için düşük hız gravity dengelemesi eklendi.
- 56 compile/83 headless/90 Studio, deterministik paket, Python/JS ve gerçek HTML overflow/broken-image kontrolü geçti. Ana Studio,lab ve açık yerel demoda90 test; demoda5 araç bağlı/upright. Başarısız bound-prototype baseline ve ilk seating setup çıktıları ayrı saklandı; fresh factory/seating retest geçti.
- iPhone7/13 ve iPadA16 landscape:9 ikon yüklenir, min84.5x58.5px, overlap yok. Küçük telefon help/dial çakışması ölçülüp help açıkken dial ölçeği düzeltildi. Gaz1→0 drag-out,brake,left/right,reverse,HB/P,help/exit ve TouchGui restorasyonu geçti. Kullanıcı açık görsel onay verdi.9 resim upload edildi, ledger korunur; ISC/FeatherMIT notice eklendi.
- Kaynak/UI/Tune gerçek ana Studio'ya ve ayrı demoya aktarıldı; kullanıcı geometrisi/R3dTuxedo/baseplate/spawn korunur. Tüm başlatılan Play ve simülasyon durduruldu; publish yok. Public/yerel paketler güncel; yeni binary ayrı pencerede yeniden açılmadı. GitHub push/CI bu kayıtta henüz tamamlandı sayılmıyor.

## 2026-10-29T21:09:46+03:00
- 0.3 kaynak098e2a527dadbab933608f24e01fa72c2d525f14 normal commit/push ile GitHub main'e gönderildi. Validate40927928835 / contracts123638325128 completed/success: https://github.com/yagizxzf/A-XZF-Tune/actions/runs/40927928835.
- Son ana Studio Edit ve source/editor eşitliği kontrolü geçti: iki gerçek Tune'da Türkçe rehber/P ve statik park kaynak düzeltmesi kurulu. Lab/delivery sadece Edit peer, aktif multiplayer/Play yok; cihaz simülasyonu default. Yeni native dosya yeniden ayrı pencerede açılmadığı sınırı HANDOVER'da korunur.
- ROADMAP0.3 teslimi tamamlandı, HANDOVER ve belgeler kodla tutarlı. Bu kayıt ayrı docs commit'idir; kaynak testi tekrar gerektiren kod değişikliği yok.

## 2026-10-29T23:29:48+03:00
-0.4: kullanıcı fizikselpedal/HBgörselleri+gruplandırılmışmobilUI istedi. Mobiloyunofficialstore screenshotları yalnızcalayoutreferansı olarak incelendi. Built-inimage_gen ile özgünatlas ve metal/kauçuk okdüğmeleri üretildi; userfizikselUI'yi onayladı, sonrasında direksiyonresmini sol/sağile değiştiripuygula dedi.5runtimegrafik yüklendi,source/prompt/provenance ui/art/v4; eskiLucidehakları korunur.
-Alt-sol yön, alt-sağpedal, ayrıHB ve utilitygrupları; topbar hit problemi ölçülüp utility105designY'ye taşındı. Preload/nativefallback, amberstate, touchhelpdefaultgizli. iPhone7/13/iPadA16landscape5loaded/1GUI/overlap0; min58.5x50.7; tüm9işlem, dragrelease,help/fallback/exitrestoration geçti.
-Eskiwheel ileri+0.2667rad vsbeklenen-0.8(10stud/s,1.25radius,.1dt): tersyön ve fizikdtcapgörselhızhatası. WheelMotion+clientWheelVisuals fullvisualdt/Transform, hubaxes, perwheelpointvelocity, HB/parklock; force/authorityserverda. Main/proto/importileri/geri/rölanti/movingHBprobeları geçti. Yanlışphase-frame ilkprobe ve uygunolmayanHBsetupfalseçıktıları tutuldu, düzeltilmişpaired/movingtestgeçer.
-61compile(59paket+2kaydedilendiagnosticprobe)/93headless/deterministikbuild, main/delivery100Studio geçti. Importdrive/Fleet ve4importjitterregresyonugeçer; temporarymotortagcleanup4baseline. Mainimportmean31.66stud/s,200.67wheelRPM, omegaerror0.000074rad/s.5cardelivery20motorboundupright100unit.
-AsılmainStudio'ya sources/UI/Tune0.4aktarıldı, modeleözelayarlar/geometrikorundu. Public/nativepaketleryenilendi; binaryayrıyeniwindow'daaçılmadı, açıkdemodoğrulandı. TümPlay/devicekapalı,publishyok. Githubpush/CI bu kayıttahenüztamamlandıdeğil.

## 2026-10-29T23:33:25+03:00
- 0.4 kaynak1d92502e0a7c441b19a4971dd4278fb436571323 GitHub main'e gönderildi. Validate40949713762 completed/success: https://github.com/yagizxzf/A-XZF-Tune/actions/runs/40949713762.
- Client analyzer çalıştırıldı: syntax0, beklenmeyen global0. Roblox tanımları bulunmadığı için287 tanı satırı var; tam Roblox-aware type-check başarısı iddia edilmiyor. Kayıt evidence/v4-client-analysis.json.
- Main Vehicle/WheelVisuals/Cockpit açık editör ve Source eşitliği doğrulandı. Lab/delivery sadece Edit peer; cihaz simülasyonu default, Play yok. Doğrulanmış headless export/render yardımcıları kapatıldı, kullanıcı önizleme sunucusu açık. Bu son kayıt ve devir notu ayrı docs commit'idir; kaynak değişikliği yok.
