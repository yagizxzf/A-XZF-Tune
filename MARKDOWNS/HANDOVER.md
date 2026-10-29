# Güncel devir

Son güncelleme: 2026-10-29T23:29:48+03:00. Okuma sırası: MARKDOWNS/AGENTS.md → HANDOVER.md → ROADMAP.md → PROGRESSION.md son kayıtlar.

Kök C:/Users/yagiz/Desktop/Projects/Life IS Roblox/A-XZF-Tune; dal main, origin https://github.com/yagizxzf/A-XZF-Tune. Bütün geliştirme burada. Önceki0.3 kaynak098e2a5 ve docs ee9717c/CI40928186558 success. Bu0.4 kaynak/test/paket değişiklikleri hazır; yeni push/CI bu kayıtta henüz başarılı sayılmıyor.

## Çalışan0.4

Kullanıcı fiziksel pedal/el freni görselleri ve gruplandırılmış mobil kontrol istedi, ardından önizlemeyi açıkça onayladı. Son isteği: direksiyon resmi yerine temaya uygun sol/sağ düğmeleri yapıp uygula. Bu doğrudan uygulama yetkisiyle değiştirildi; yeni onay beklenmiyor.

AktifMobile: alt solda metal/kauçuk sol-sağ; sağ altta gaz/fren pedalı; üstünde ayrı el freni; sol üstteP/R/TUŞ/ÇIK. Yardımcı grup Roblox topbar'ından aşağıda(20,105 design). TUŞ ile ortada açılan klavye yardımı mobilde ilk başta gizli; kontroller kalır.5 görsel asenkron preload, yüklenmezse nativeetiket fallback, amberpress/toggle. Kaynak ui/build.py + ui/rbx.json; generatedui/runtime; ui/REVIEW.md yeni tercihler. Art ui/art/v4/control-atlas.png ve steering-buttons.png, built-in image_gen; PROMPTS/provenance/uploads kayıtlı. Orijinal atlasın steering-wheel hücresi kullanılmaz. Önceki Lucide files/notice korunur, aktifMobile ikon kullanmaz. ui/assets.json upload ledger;5 yeni asset, yakın-eş rasterhash alias'ı yeniden yüklenmedi.

Teker sorunları doğrulandı: eski ileri+spin ters yöndeydi ve fizikdt1/30 görsel hızı düşürüyordu. Shared/WheelMotion (angularVelocity/rpm/advance) ile doğru yön/tam dt; Powertrain aynı roadRPM formülünü kullanır. Yeni Client/WheelVisuals yerelPreSimulation Motor6D.Transform uygular; Server/VehicleC0 yalnızca suspension/steering/baseorientation. Rig metadata AXZFWheelVisual tag,Radius/RollAxis/ForwardAxis/Rear. Her bağlanan Vehicle için çalışır, sadece standartFleet tag'ine bağlı değildir.250studgörselculling; kuvvet/yetki/remoteclient'a taşınmaz. HBarka/parktekerleri kilitler; durmuş araçta850rpm rölanti teker döndürmez. Bu bağımsız wheel-inertia/slip/clutch simülasyonu değildir.

0.3 fizik/park/49 alanlı Türkçe Tune rehberi korunur. P ayrı latchedpark, Space arkaHB; requestexit/timeoutta korunur. Main iki Tune güncellendi, import Radius1.5/FWD/TorqueScale5/Power1 korundu; şablon ve4 sources içinde RPM/yarıçap açıklaması eklendi. TuneEditor Edit-only, mevcutTune için açık overrides; legacyTune yürütmez. Eski Handbrake=P remap'i varsa Park benzersizbaşka tuş olmalı.

## Gerçek kontroller

61 Luau syntaxcompile(59packaged +2diagnosticprobes),93headless ve deterministikbuild geçti. Main/delivery100/100Studio;10yeni WheelMotion case. Aktifmainimport canlıwheel maxomegaerror0.000074rad/s, jointposeerror0.000691rad; ileri/geri/prototype/import pairedprobes geçer. Rölanti850, wheelphaseDelta0; hareketliHB64.08stud/s rearDelta0 front0.2227rad/0.1s. İlk waiter probe yanlış dt/speed karesine bakıyordu; önceki dt ile eşlenen probe geçer, eski false çıktı korunur. İlkHBdenemelerinde araç sınırlı pistten çıkmış veya durmuştu; movingretest ayrı tutulur.

Mobil iPhone7/13/iPadA16 landscape:5imagesloaded,1cockpit,9buttons,overlap0; minaux58.5x50.7px, steer94.25x130/gas97.5x185.25/brake123.5x143/HB117x117. P, gaz,fren,sol/sağ,R,HB,help/exit ve drag-out release geçti. EmptyImage fallback/restoration geçer. Main P/E ve WheelVisualsvarlığı geçti. Fizikselmultitouch/gamepad/0.4portrait/newmulti/adversenetwork profili yapılmadı; mevcutplaceLandscapeSensor.

ImportDrive+Fleet lifecycle geçti; temporaryriglerden sonra4baselineWheelTags kalır.4import180samplejitter angularRMS0.00261/0.03656/0.05084/0.00316rad/s, heightRange0. Delivery5car/20wheelTag tümüboundupright,100unit. Evidence evidence/v4-*.json; ui/shots/v4-studio-*.png; docs/TESTING.md#04-validation. Kullanılmış istemci ölçüm kaynakları tools/visual-probes/*.luau; client-only, input göndermez. HTMLkontrolü AXZF_UI_CHECK_RECORD=evidence/v4-html-checks.json ile alındı; v3 geçmişi korunur.

## Studio ve paketler

Main built-in22a56821-c454-406f-86dd-4ea0c00752d6, A-XZF-Tune place72435697524161 güncel0.4, Edit. Kullanıcının penceresi kapatılmadı; R3dTuxedo/baseplate/spawn ve geometri korunur, canlıpublishyok. Ana eskipencerede communityplugin olmadığı için sadecebuhedefe built-in/SES installer kullanılır. MevcutStarterPlayerScripts'i yenidenparentetme. ScriptEditorService.UpdateSourceAsync +GetEditorSource; açıkbuffer/Source eşitliği birframegecikebilir.

Lab communityinstance:i5h-8xn (built-in4b297fbf-84ef-47c1-9ab1-c06845d9c69a), deliveryinstance:9jh-9ve (e7f88962-485a-4a3b-aefa-159f877bd2f3), ikisiEdit. BaşlatılanPlay ve devicesimulation kapatıldı. Persistentnode_repl rpc/mt/installCode/tuneUpgradeCode bağlantısı var. Diğer eski kullanıcı Studio pencerelerini kapatma.

Public build/A-XZF-Tune.rbxmx ve A-XZF-Tune-Demo.rbxlx güncel. Yerel dış-art nativebundle build/AXZF-CompatibilityCars.rbxm ve build/A-XZF-CompatibilityDemo.rbxl yenilendi, Gitignore. Açıkdemo aynısrc/Tune ilePlay'de doğrulandı; yeni binary ayrıwindow'da yenidenaçılmadı. Dışcarartını MIT diye dağıtma.

Komutlar: python tools/build.py; python tools/check.py --compiler .tools/luau/luau-compile.exe --runtime .tools/luau/luau.exe. Optional python tools/export_compatibility.py, rbxmk0.9.1+uyumluAPI descriptor; rawsizealias ve Mass=1.2*volume workaround docs/ASSETS.md. RojoClientWheelVisuals yeni path'i içerir; manuelkurulumda bütünClient scriptlerini taşı. UIexporterheadless9333eskiDOM'a bağlanırsa yalnızca doğrulanmış headlesscdp-*helperkapat; görünür tarayıcıyı kapatma.

## Sıradaki adım

0.4 değişikliklerini commit/push et, ValidateCI sonucunu oku ve PROGRESSION/ROADMAP/HANDOVER teslimini güncelle. Bu4 yeni süreklilik dosyası oluşturulmadı, mevcutlar devamettirildi. Stabil1.0 kapıları fizikselinput, kötüağ/streaming, uzunsoak/toplamprofil, Roblox-awaretyping ve modernA-Chassis1.7.2 testleri açık; tamamlandı sayma.
