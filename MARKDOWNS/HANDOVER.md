# Devir

Son güncelleme: 2026-10-29T15:39:07+03:00 (kaynak GitHub'a gönderildi, remote CI geçti).

Okuma sırası: AGENTS.md → HANDOVER.md → ROADMAP.md → PROGRESSION.md son kayıtları (hepsi MARKDOWNS/ içinde).

Kök: C:/Users/yagiz/Desktop/Projects/Life IS Roblox/A-XZF-Tune. Git origin: https://github.com/yagizxzf/A-XZF-Tune, boş main; clone yapıldı. GitHub connector yazma yetkili; gh oturumu yok. Sistem rojo komutu Aftman'da yapılandırılmamış. Python ve Git mevcut. Studio MCP bağlı: A-XZF-Tune, placeId 72435697524161, Edit. Workspace taban/spawn dışında boş; ServerStorage.R3dTuxedo korunacak.

Referans A-Chassis README ve güncel release metadata incelendi: v1.7.2-stable. Kaynak kod alınmadı. Kullanıcı bağımsız, açık kaynak, modüler, performans/QOL odaklı araç kiti; prototip ve dış kaynaklı parçalı araçla gerçek testler ve tam belgeler istiyor.

## Güncel çalışan durum

Bağımsız server-owned raycast araç kiti, 28 Luau dosyası. Kaynak src/, kullanıcı belgeleri docs/, özgün araç/pist examples/, testler tests/, paketleme tools/. Başlangıç bilgilerinin üzerindeki bu güncel bölüm geçerlidir. Tüm dosyalar kullanıcının ek talimatıyla yalnızca bu Git kökünde.

`python tools/build.py` public model/demo üretir. `python tools/check.py --compiler .tools/luau/luau-compile.exe --runtime .tools/luau/luau.exe`: 28 compile, 58 headless case, deterministik build geçti. Luau 0.744 hash doğrulandı, .tools Git dışında. Studio birim testi 65/65. İki araç drive, handling, fleet lifecycle, 12 araç solve timing, iki gerçek istemci security, keyboard/focus, iPhone/iPad landscape denemeleri geçti. Kanıt docs/TESTING.md ve evidence/studio-results.json.

Ana Studio Edit: Workspace.AXZF_Prototype, AXZF_ImportedCar, AXZF_TestTrack bilinçli tutuldu. ServerStorage.AXZFExamples.ImportedCarSource inert kaynak. Var olan R3dTuxedo/baseplate/spawn korunur. Yabancı karantina paketi kaldırıldı; yabancı kod çalıştırılmadı. Harici araç 14215126016, 47 BasePart/45 MeshPart. Art MIT olarak dağıtılmaz; yerel build/Studio-With-ImportedCar.rbxlx ve evidence/imported-geometry.json ignore edilir. Mesh InitialSize ölçeği yeniden açılarak doğrulandı. Public demo özgün parça araç üretir; dış model reçetesi docs/ASSETS.md.

Studio pluginleri Roundy/Animation Spoofer gibi kit dışı hatalar veriyor; genel temiz konsol iddiası yok. Play oturumları durduruldu, simulator defaulta döndü. Son client değişikliği: textbox focus brake sonrasında focus release clear ve global event cleanup; gerçek istemci regresyonu geçti.

Release candidate hazır; stabil v1.0 tamamlanmadı. Fiziksel cihaz/gamepad, portre, kötü ağ/streaming, death-reset-reconnect, uzun soak/toplam profil/type-aware analiz açık. Ayrıntı docs/READINESS.md ve ROADMAP.md.

GitHub teslimi: main kaynak commit `f870ffcabee823d985be5b95d7cb5aaecc0d0796`; Validate run `40874968917` completed/success: https://github.com/yagizxzf/A-XZF-Tune/actions/runs/40874968917. İlk README connector ile, kaynak commit/push connector taşıma hatası ardından mevcut Git credential manager ile yapıldı. Yerel dal main, origin/main ile eşlendi. Devir kaydı ayrı takip commit'iyle gönderilir.

Sıradaki somut geliştirme: docs/READINESS.md içindeki adoption testlerini tamamlayıp v1.0 kararı vermek. Şu an release candidate kullanılabilir; kullanıcıya çalışan demo ve yerel gerçek araçlı sahne yolları verilir. Canlı Roblox publish yapılmadı.
