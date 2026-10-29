# Güncel devir

Son güncelleme: 2026-10-29T19:09:42+03:00. Okuma sırası: MARKDOWNS/AGENTS.md → HANDOVER.md → ROADMAP.md → PROGRESSION.md son kayıtlar.

Kök: C:/Users/yagiz/Desktop/Projects/Life IS Roblox/A-XZF-Tune. Dal main; origin https://github.com/yagizxzf/A-XZF-Tune. 0.2 kaynakları07db86c ve platform düzeltmesi2d251034caf13832b20fa2d3f70c75ad1ac20aaf GitHub main'e gönderildi. Remote Validate40903141125 completed/success: https://github.com/yagizxzf/A-XZF-Tune/actions/runs/40903141125. İlk07db86c CI paket sıralaması nedeniyle başarısızdı; düzeltme ve başarılı tekrar PROGRESSION'da korunur. Tüm geliştirme bu klasörde kaldı.

## Çalışan sürüm

0.2.0-rc.1: bağımsız dört raylı araç; ortak hız anlık görüntüsü + örtük 4 temas çözümü, VectorForce/Torque desteği; güvenli otomatik düzeltme; kullanıcının açıkça onayladığı yuvarlak HUD, gizlenebilir/değiştirilebilir tuşlar, ayrı mobil kontroller, P gibi araç Tune remap'i; özel texture ile istemci duman/toz; açıklamalı araç Tune; Edit-only Migration.inspect/convert/fromSelection.

Kaynak: src/, examples/VehicleTune.luau; GUI: ui/runtime ve ui/build.py; VFX: vfx/runtime ve vfx/vehicle. Runtime kit artık UI, VFX ve VehicleTune şablonunu içerir. Runtime kurulumunda bütün servis klasörlerini taşı; docs/INSTALLATION.md tablosu geçerli.

## Gerçek sonuçlar

49 Luau compile, 68 headless, deterministik build, Python compile, JS syntax/diff kontrolleri geçti. Studio 75/75. Üç gerçek A-Chassis sedan/polis/SUV dönüşümü ve ilk import araç drive/brake/steer/watchdog/cleanup/rebind geçti. Prototip + bu dört araç jitter eşikleri altında. Aynı orijinal importta açısal RMS 1.96966 → 0.02970 rad/s. Recovery ters/havada/dik/kapalı alan/alan açılması ve ayrıca dolu koltukta geçti. Fleet pretag/ancestry/retag/cleanup ve iki gerçek istemci yetki/bozuk/replay/drive/exit testleri geçti. Yeni 12 araç solve ölçümü ort.0.781 / p95 1.109 ms; toplam engine/GPU/network profili değildir.

iPhone 7/13 landscape, iPhone 13 portrait ve iPad 6 landscape yerleşimleri kontrol edildi; en az48 px düğmeler, düğme/gösterge çakışması yok. GO/PARK/KEYS/EXIT, Tune.Handbrake=P, sürükleyip dışarı bırakınca gaz1→0 ve native TouchGui restorasyonu gerçek simulator input ile geçti. Fiziksel multitouch/gamepad yapılmadı.

Kanıt: docs/TESTING.md, docs/COMPATIBILITY.md; evidence/v2-*.json; ui/shots; vfx/vehicle/checks. 0.1 sonuçları tarihsel olarak korunur. VFX özel dokuları 123244819470159 ve 101186639768027; uploaded map vfx/vehicle/assets.json. Dört hold anı ve canlı client burst kontrol edildi; server Workspace emitter0, preview leftovers boş.

## Yerel gerçek araçlı sahne

**build/A-XZF-CompatibilityDemo.rbxl** diskte hazır; kaynaklardan ve Studio native dışa aktarımından üretildi, yeniden açıldı. Son bağımsız dosyada beş araç doğru kütle/yükseklik/upright ile bağlı ve75 test geçti (evidence/v2-delivery-file.json). Model artı Git dışında; public demo yalnızca özgün prototipi üretir.

Native source bundle build/AXZF-CompatibilityCars.rbxm de ignore edilir. Opsiyonel helper python tools/export_compatibility.py, rbxmk0.9.1 ve .tools/rbxmk/API-Descriptor.json gerektirir. tools/prepare_rbxmk_descriptor.py tam API dump'ını eski araca uyarlar. Decoder raw size aliaslarını korumak için descriptor olmadan okur, binary service flags için descriptor ile yazar. Güncel PhysicalProperties eski converter'da bozulduğundan yerel araç Tune.Mass değerleri doğru authored yoğunluk1.2 üzerinden açık yazılır; kök serializedphysics kaldırılır. Public runtime/migrator bu converter'a bağımlı değildir.

Son Studio community ID instance:9jh-9ve (PID53104), yerel CompatibilityDemo, Edit. Önceki test lab instance:i5h-8xn, Edit; inert orijinaller ve kaynaklar burada durur. Community bridge persistent node_repl rpc ile mevcut; tools discovery namespace olarak görünmediği için stdio istemci kullanıldı. VFX/GUI Studio işleri community MCP ile, built-in sadece VFX upload ve genel non-VFX test/asset işleri için kullanıldı.

Kullanıcının asıl eski Studio A-XZF-Tune (22a56821-c454-406f-86dd-4ea0c00752d6, place72435697524161) kapatılmadı/yayınlanmadı; yeni HUD/VFX'nin son teslim hedefi yukarıdaki ayrı yerel demo ve repo paketidir. R3dTuxedo/baseplate/spawn korunur. Yeni açılan başarısız/ara CompatibilityDemo yardımcı pencereleri kapatıldı; önceden var olan kullanıcı pencerelerine dokunulmadı. Son Play durduruldu. Canlı Roblox publish yok.

## Sıradaki somut adım

İstenen0.2 özellikleri/test/belge/paket/GitHub teslimi tamamlandı; bu güncel teslim kaydı ayrı docs commit'i olarak gönderilir. Kullanıcı için açılacak dosya build/A-XZF-CompatibilityDemo.rbxl (Play ile5 araç oluşur); public GitHub demosu yalnızca özgün prototiptir. Runtime/paket kaynak CI2d25103 üzerinde geçti.

Stabil v1.0 ilan etme: fiziksel cihazlar, kötü ağ/streaming, tam reset-reconnect, uzun soak/toplam profil, Roblox-aware typing ve modern A-Chassis1.7.2 model uyumluluğu açık. Kullanıcı başka geliştirme isterse bu dosya ve ROADMAP ile devam et. Legacy araç artı Git'e ekleme. Asıl kullanıcı Studio penceresini kapatma/yayınlama.

## GUI hotfix — bu bölüm önceki teslim hedefi bilgisini günceller

Gerçek görünür ana A-XZF-Tune Studio22a56821-c454-406f-86dd-4ea0c00752d6 güncellendi; artık GUI/VFX dahil son runtime burada da kurulu. UI daha önce yalnızca ayrı demo/lab'a aktarılmıştı. Ana Studio Edit, R3dTuxedo/araçlar korundu, publish yok. Açık Fleet editörü de SES ile eşitlendi. Kullanıcı Play'e basıp DriveSeat'e oturunca GUI açılır; H/E/ikinci araç/respawn testleri geçti. Kanıt evidence/gui-hotfix-*.json. Local backup evidence/local-pre-hud-main.json ignore altında.

Kod: UI hazırlama Bootstrap'tan default Fleet.start'a taşındı; Driver/Cockpit replicated bağımlılıkları bekleyip eksikleri raporlar. tools/build.py installer mevcut özel container'ları yeniden parent etmez ve Source yerine UpdateSourceAsync ile editör senkronunu korur.49 compile/68 headless/75 Studio geçti. Public ve yerel gerçek araçlı paketler güncellendi. Son hotfix commit/push/CI sırada.
