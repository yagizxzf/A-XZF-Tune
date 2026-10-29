# Güncel devir

Son güncelleme: 2026-10-29T23:33:25+03:00. Başlangıç okuma sırası: MARKDOWNS/AGENTS.md, HANDOVER.md, ROADMAP.md, ardından PROGRESSION.md son kayıtları.

Kök: C:/Users/yagiz/Desktop/Projects/Life IS Roblox/A-XZF-Tune. Dal main; origin https://github.com/yagizxzf/A-XZF-Tune. Tüm geliştirme burada kaldı. Güncel 0.4 kaynak commit'i 1d92502e0a7c441b19a4971dd4278fb436571323 main'e gönderildi. Validate40949713762 completed/success: https://github.com/yagizxzf/A-XZF-Tune/actions/runs/40949713762. Son teslim ve analiz notu ayrı docs commit'idir.

## Çalışan sürüm ve kullanıcı kararları

0.4.0-rc.1 tamamlandı. Kullanıcı fiziksel pedal/el freni görselleri ile gruplandırılmış mobil kontrolleri onayladı. Ardından direksiyon resmi yerine aynı temada sol/sağ düğmeleri yapıp uygulamamızı açıkça istedi; bu son değişiklik de uygulandı. Bekleyen onay yok.

Aktif mobil görünüm: alt solda metal/kauçuk sol ve sağ düğmeleri, sağ altta gaz/fren pedalları, ayrı el freni görseli, sol üstte P/R/TUŞ/ÇIK grubu. Yardımcı grup Roblox üst çubuğunun altında (20,105 design). Mobilde klavye yardımı başlangıçta gizli; TUŞ ile açılır, sürüş kontrolleri görünür kalır. Beş resim ön yüklenir; yüklenemezse native metin yedeği görünür, giriş çalışmayı sürdürür. Basma/açık durumları amber renkle belirtilir.

UI kaynağı ui/build.py ve ui/rbx.json; generated veri ui/runtime, davranış Cockpit.luau. Art: ui/art/v4/control-atlas.png ve steering-buttons.png; built-in image_gen kullanıldı. Tam prompt, provenance ve yükleme kayıtları aynı klasörde. Atlasın direksiyon hücresi kullanılmaz. Önceki Lucide dosyaları/bildirimi tarihsel kaynak olarak korunur; aktif Mobile verisi 5 art referansı ve 0 icon referansı içerir. ui/assets.json yükleme kaydıdır; değişmeyen resmi tekrar yükleme. Yakın eş raster hash'i mevcut HB asset'ine alias edildi.

## Teker mimarisi

Eski kod ileri sürüşte yanlış +X yönünde dönüyor, görsel süreyi fizik dt sınırı olan1/30 ile kısıtlıyordu. Shared/WheelMotion doğru yön ve tam görsel dt ile roadRPM hesaplar; Powertrain aynı dönüşümü kullanır. EngineRPM = wheelRPM × vites × final oranı, idle/redline sınırları içinde; rölantide sabit aracın tekeri dönmez.

Server/Vehicle motor C0 alanında süspansiyon, direksiyon ve hub taban yönünü tutar. Yeni Client/WheelVisuals, AXZFWheelVisual tag'li motorların metadata'sını okuyup PreSimulation'da yalnızca yerel Motor6D.Transform döndürür. Radius/RollAxis/ForwardAxis/Rear metadata'sı her Vehicle.new için kurulur; yalnızca standart Fleet tag'ine bağlı değildir. Per-wheel nokta hızı kullanılır; arka HB ve park kilitleri uygulanır.250 stud görsel mesafe sınırı var. Fizik kuvvetleri, ağ sahipliği ve yetki sunucuda kalır. Bu, bağımsız teker ataleti/slip/clutch simülasyonu değildir.

Manuel kurulumda bütün Client dosyalarını taşı: Driver, VehicleEffects ve WheelVisuals. Rojo ve normal paket yeni dosyayı içerir. Sadece yeni server Vehicle'ı kopyalayıp WheelVisuals'ı unutmak tekerleri görsel olarak sabit bırakır.

0.3 park/fizik/49 alanlı Türkçe Tune rehberi korunur. P ayrı kalıcı park, Space arka el freni; park isteği çıkış/timeout ile bırakılmaz. Gerçek main iki araç ve4 kaynak Tune güncel; import Radius1.5/FWD/TorqueScale5/Power1 korundu. Şablona yol RPM/Radius açıklaması eklendi. TuneEditor Edit-only ve mevcut Tune için açık overrides ister; legacy Tune çalıştırılmaz. Eski Handbrake=P remap'inde Park başka benzersiz tuş kullanmalı.

## Son doğrulamalar

61 Luau compile (59 paket script'i +2 diagnostic probe),93 headless ve deterministik paket geçti. Main ve açık delivery demoda100/100 Studio testi geçti. On yeni WheelMotion testi var. Standalone client analyzer: 0 syntax error ve 0 beklenmeyen global; Roblox type definitions olmadığı için287 tanı satırı bulunuyor, tam Roblox-aware type-check geçti denmez.

Canlı ileri/geri/prototip/import teker ölçümleri geçti. Main import ort.31.66 stud/s,200.67 wheelRPM; azami omega hata0.000074 rad/s, eklem pozu hata0.000691 rad. Hareketli HB testi:64.08 stud/s'de arka dönüş0, ön0.2227 rad/0.1s. Rölanti850, teker delta0. İlk ölçüm yanlış kare dt'sine bakıyordu; önceki kare dt/hız ile eşlenen test geçti. Önceki false kayıtları korunur. İlk HB denemelerinde hareket koşulu sağlanmamıştı; başarılı moving retest ayrıdır.

Mobil iPhone7/13 ve iPadA16 landscape:5 resim loaded,1 cockpit,9 düğme, overlap0. En küçük yardımcı hedef58.5×50.7px; telefon yön düğmesi94.25×130, gaz97.5×185.25, fren123.5×143, HB117×117. P, gaz/fren, sol/sağ, R, HB, yardım ve çıkış girişleri; dışarı bırakmada sıfırlama; image fallback ve TouchGui restorasyonu geçti. Fiziksel multitouch/gamepad,0.4 portre ve yeni multiplayer/adverse-network testi yapılmadı; place LandscapeSensor.

Import DriveTest/Fleet yaşam döngüsü geçti; geçici rigler silinince4 baseline wheel tag kaldı. Dört import jitter testi geçti: açısal RMS0.00261/0.03656/0.05084/0.00316rad/s; heightRange0. Delivery5 araç/20 motor, tümü bound/upright,100 unit geçti. Main P/E ve WheelVisuals varlığı doğrulandı. Kanıt: evidence/v4-*.json, ui/shots/v4-studio-*.png ve docs/TESTING.md#04-validation. Kaydedilmiş istemci ölçümleri tools/visual-probes; input göndermez, Studio Client bağlamında çalışır. HTML kayıt adı için AXZF_UI_CHECK_RECORD env kullan; tarihsel v3 kayıtlarını yeniden yazma.

## Studio, paketler ve komutlar

Asıl kullanıcı Studio: A-XZF-Tune place72435697524161, built-in22a56821-c454-406f-86dd-4ea0c00752d6.0.4 kurulu, Edit. Vehicle/WheelVisuals/Cockpit Source ile açık editör buffer'ı eşitliği geçti. R3dTuxedo/baseplate/spawn ve geometri korundu; kullanıcı penceresi kapatılmadı, canlı publish yok. Bu eski pencerede community plugin yüklü değil; yalnızca bu hedef için mevcut built-in bağlantı ve SES installer kullanılır.

Lab communityinstance:i5h-8xn (built-in4b297fbf-84ef-47c1-9ab1-c06845d9c69a), deliveryinstance:9jh-9ve (e7f88962-485a-4a3b-aefa-159f877bd2f3). İkisi Edit, aktif test yok; cihaz simülasyonu default. Persistent node_repl rpc/mt/installCode/tuneUpgradeCode bağlantısı mevcut. Diğer eski kullanıcı Studio pencerelerini kapatma.

Public build/A-XZF-Tune.rbxmx ve A-XZF-Tune-Demo.rbxlx güncel. Yerel dış-art bundle build/AXZF-CompatibilityCars.rbxm ve build/A-XZF-CompatibilityDemo.rbxl yenilendi, Git dışında. Açık demo güncellenip test edildi; yeni binary ayrı pencerede yeniden açılmadı. Dış araç sanatını MIT diye dağıtma.

Komutlar: python tools/build.py; python tools/check.py --compiler .tools/luau/luau-compile.exe --runtime .tools/luau/luau.exe. Optional python tools/export_compatibility.py; rbxmk0.9.1 ve uyumlu API descriptor gerekir. Native size alias/Mass=1.2*volume workaround docs/ASSETS.md içinde.

Studio güncellemelerinde ScriptEditorService.UpdateSourceAsync ve okumada GetEditorSource kullan; mevcut StarterPlayerScripts gibi özel container'ları yeniden parent etme. UI export9333 headless Edge açık kalırsa yalnızca doğrulanmış headless/cdp-* yardımcısını kapat; aksi halde eski DOM'a export bağlanabilir. Görünür kullanıcı tarayıcısına dokunma. Bu oturumun headless export/render yardımcıları kapatıldı;8870 önizleme sunucusu kullanıcı için açık bırakıldı.

## Devam

İstenen0.4 uygulama, test, paket ve başarılı kaynak CI teslimi tamamlandı. Son devir notu ayrı docs commit'iyle gönderilir. Kullanıcı ana Studio'da Play ve DriveSeat ile deneyebilir. Stabil1.0 için önceki fiziksel cihaz, kötü ağ/streaming, uzun soak/toplam profil, Roblox-aware typing ve modern A-Chassis1.7.2 test kapıları açık kalır; tamamlandı sayılmaz.
