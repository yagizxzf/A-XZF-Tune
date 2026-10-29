# Güncel devir

Son güncelleme: 2026-10-29T18:16:00+03:00. Okuma sırası: MARKDOWNS/AGENTS.md → HANDOVER.md → ROADMAP.md → PROGRESSION.md son kayıtlar.

Kök: C:/Users/yagiz/Desktop/Projects/Life IS Roblox/A-XZF-Tune. Dal main; origin https://github.com/yagizxzf/A-XZF-Tune. İkinci geliştirme kaynakları henüz commit/push aşamasında; eski HEAD 7a6d628. Tüm geliştirme bu klasörde kaldı.

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

Kaynak+paket+belgeyi commit/push et, head için GitHub Validate sonucunu kontrol et ve bu devir/PROGRESSION/ROADMAP teslim durumunu gerçek sonuca göre güncelle. Kullanıcıya çalışan yerel .rbxl ve migration/uyumluluk rehberini ver. Stabil v1.0 ilan etme: fiziksel cihazlar, kötü ağ/streaming, tam reset-reconnect, uzun soak/toplam profil, Roblox-aware typing ve modern A-Chassis1.7.2 model uyumluluğu hâlâ açık. Ayrıntı ROADMAP.md ve docs/READINESS.md.
